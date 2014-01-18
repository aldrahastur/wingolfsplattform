# -*- coding: utf-8 -*-

# This extends the your_platform User model.
require_dependency YourPlatform::Engine.root.join( 'app/models/user' ).to_s

# This class represents a user of the platform. A user may or may not have an account.
# While the most part of the user class is contained in the your_platform engine, 
# this re-opened class contains all wingolf-specific additions to the user model.
#
class User

  attr_accessible :wingolfsblaetter_abo, :hidden

  # This method returns a kind of label for the user, e.g. for menu items representing the user.
  # Use this rather than the name attribute itself, since the title method is likely to be overridden
  # in the main application.
  # Notice: This method does *not* return the academic title of the user.
  # 
  # Here, title returns the name and the aktivitaetszahl, e.g. "Max Mustermann E10 H12".
  # 
  def title
    ( name + "  " + cached_aktivitaetszahl ).strip if name && cached_aktivitaetszahl
  end
  
  # This method returns the bv (Bezirksverband) the user is associated with.
  #
  def bv
    (Bv.all & self.groups).try(:first).try(:becomes, Bv)
  end

  # This method returns the aktivitaetszahl of the user, e.g. "E10 H12".
  #
  def aktivitaetszahl
    if self.corporations
      self.corporations
        .sort_by { |corporation| corporation.membership_of(self).valid_from } # order by date of joining
        .collect do |corporation| 
        if not (self.guest_of?(corporation)) and not (self.former_member_of_corporation?(corporation))
          year_of_joining = ""
          year_of_joining = corporation.membership_of( self ).valid_from.to_s[2, 2] if corporation.membership_of( self ).valid_from
          #corporation.token + "\u2009" + year_of_joining
          token = corporation.token; token ||= ""
          token + aktivitaetszahl_addition_for(corporation) + year_of_joining
        end
      end.join( " " )
    end
  end

  def cached_aktivitaetszahl
    Rails.cache.fetch([self, "aktivitaetszahl"]) { aktivitaetszahl }
  end
  
  def aktivitaetszahl_addition_for( corporation )
    addition = ""
    addition += " Stft" if self.member_of? corporation.descendant_groups.find_by_name("Stifter")
    addition += " Nstft" if self.member_of? corporation.descendant_groups.find_by_name("Neustifter")
    addition += " Eph" if self.member_of? corporation.descendant_groups.find_by_name("Ehrenphilister")
    addition += " " if addition != ""
    return addition
  end

  # Fill-in default profile.
  #
  def fill_in_template_profile_information
    self.profile_fields.create(label: :personal_title, type: "ProfileFieldTypes::General")
    self.profile_fields.create(label: :academic_degree, type: "ProfileFieldTypes::AcademicDegree")
    self.profile_fields.create(label: :cognomen, type: "ProfileFieldTypes::General")
    self.profile_fields.create(label: :klammerung, type: "ProfileFieldTypes::Klammerung")

    self.profile_fields.create(label: :home_address, type: "ProfileFieldTypes::Address")
    self.profile_fields.create(label: :work_or_study_address, type: "ProfileFieldTypes::Address")
    self.profile_fields.create(label: :phone, type: "ProfileFieldTypes::Phone")
    self.profile_fields.create(label: :mobile, type: "ProfileFieldTypes::Phone")
    self.profile_fields.create(label: :fax, type: "ProfileFieldTypes::Phone")
    self.profile_fields.create(label: :homepage, type: "ProfileFieldTypes::Homepage")

    self.profile_fields.create(label: :study, type: "ProfileFieldTypes::Study")

    self.profile_fields.create(label: :professional_category, type: "ProfileFieldTypes::ProfessionalCategory")
    self.profile_fields.create(label: :occupational_area, type: "ProfileFieldTypes::ProfessionalCategory")
    self.profile_fields.create(label: :employment_status, type: "ProfileFieldTypes::ProfessionalCategory")
    self.profile_fields.create(label: :languages, type: "ProfileFieldTypes::Competence")
    
    self.profile_fields.create(label: :bank_account, type: "ProfileFieldTypes::BankAccount")

    pf = self.profile_fields.create(label: :name_field_wingolfspost, type: "ProfileFieldTypes::NameSurrounding")
      .becomes(ProfileFieldTypes::NameSurrounding)
    pf.text_above_name = ""; pf.name_prefix = "Herrn"; pf.name_suffix = ""; pf.text_below_name = ""
    pf.save

    self.wingolfsblaetter_abo = true
  end
  
  
  # W-Nummer  (old uid)
  # ==========================================================================================
  
  def w_nummer
    self.profile_fields.where(label: "W-Nummer").first.try(:value)
  end
  
  def self.find_by_w_nummer(wnr)
    ProfileField.where(label: "W-Nummer", value: wnr).first.try(:profileable)
  end


  # Abo Wingolfsblätter
  # ==========================================================================================

  def wbl_abo_group
    Group.find_or_create_wbl_abo_group
  end
  private :wbl_abo_group

  def wingolfsblaetter_abo 
    self.member_of? wbl_abo_group
  end
  def wingolfsblaetter_abo=(new_abo_status)
    if new_abo_status == true || new_abo_status == "true"
      wbl_abo_group.assign_user self
    else
      wbl_abo_group.unassign_user self
    end
  end


  # Global Admin Switch
  # ==========================================================================================

  def global_admin
    self.in? Group.everyone.admins
  end
  def global_admin?
    self.global_admin
  end
  def global_admin=(new_setting)
    if new_setting == true
      Group.everyone.admins << self
    else
      UserGroupMembership.find_by_user_and_group(self, Group.everyone.main_admins_parent).try(:destroy)
      UserGroupMembership.find_by_user_and_group(self, Group.everyone.admins_parent).try(:destroy)
    end
  end

end

