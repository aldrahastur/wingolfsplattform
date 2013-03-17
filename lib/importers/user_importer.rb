# -*- coding: utf-8 -*-
require 'importers/importer'

#
# This file contains the code to import users from the deleted-string csv export.
# Import users like this:
#
#   require 'importers/user_import'
#   importer = UserImporter.new( file_name: "path/to/csv/file", filter: { "uid" => "W51061" },
#                                update_policy: :update )
#   importer.import
#   User.all  # will list all users
#
class UserImporter < Importer

  def import
    import_file = ImportFile.new( file_name: @file_name, data_class_name: "UserData" )
    import_file.each_row do |user_data|
      if user_data.match? @filter 
        handle_existing(user_data) do |user|
          handle_existing_email(user_data) do |email_warning|
            user.update_attributes( user_data.attributes )
            user.save
            user.import_profile_fields( user_data.profile_fields_array, update_policy)
            progress.log_success unless email_warning
          end
        end
      end
    end
    progress.print_status_report
  end

  private

  def handle_existing( data, &block )
    if data.user_already_exists?
      if update_policy == :ignore
        progress.log_ignore( { message: "user already exists", user_uid: data.uid, name: data.name } ) 
        user = nil
      end
      if update_policy == :replace
        data.existing_user.destroy 
        user = User.new 
      end
      if update_policy == :update
        user = data.existing_user
      end
      yield( user ) if update_policy == :update || update_policy == :replace
    else
      yield( User.new )
    end
  end

  def handle_existing_email( data, &block )
    if data.email_already_exists_for_other_user?
      warning = { message: "Email #{data.email} already exists. Keeping the existing one, ignoring the new one.",
        user_uid: data.uid, name: data.name }
      progress.log_warning(warning)
      data.email = nil
    end
    yield(warning)
  end

end


class UserData

  def initialize( data_hash )
    @data_hash = data_hash
    @profile_fields = []
  end

  def data_hash_value( key )
    val = @data_hash[ key ] 
    val ||= @data_hash[ key.to_s ]
  end

  def d( key )
    data_hash_value(key)
  end

  # The filter is a Hash the data_hash is compared against.
  # The method returns true if the data_hash contains the information
  # given in the filter hash.
  #
  # Example:
  #
  #   filter = { "uid" => "1234" }
  #
  def match?( filter )
    return true if filter.nil?
    return ( @data_hash.slice( *filter.keys ) == filter )
  end

  def user_already_exists?
    existing_user.to_b
  end

  def existing_user
    User.where( first_name: self.first_name, last_name: self.last_name )
      .includes( :profile_fields )
      .select { |user| user.date_of_birth == self.date_of_birth }
      .first
  end

  def email_already_exists_for_other_user?
    return false if not self.email.present?
    if User.find_all_by_email( self.email ).count > 0 
      if user_already_exists?
        # Then the email address is the one of the user to import (update) now.
        # So, it's the same user.
        return false
      else
        # It's another user, therefore duplicate email!
        return true
      end
    end
  end

  def attributes
    {
      first_name:         self.first_name,
      last_name:          self.last_name,
      date_of_birth:      self.date_of_birth,
      updated_at:         d('modifyTimestamp').to_datetime,
      created_at:         d('createTimestamp').to_datetime,
    }
  end

  def profile_fields_array
    add_profile_field 'W-Nummer', value: self.w_nummer, type: "General"

    add_profile_field :title, value: self.personal_title, type: "General"
    add_profile_field :academic_title, value: academic_titles.join(", "), type: "General"

    add_profile_field :email, value: self.email, type: 'Email'
    add_profile_field :work_email, value: d('epdprofemailaddress'), type: 'Email'
    add_profile_field :home_email, value: d('epdprivateemailaddress'), type: 'Email'

    add_profile_field home_address_label, value: self.home_address, type: 'Address'
    add_profile_field professional_address_label, value: professional_address, type: 'Address'

    add_profile_field :home_phone, value: phone_format(d('homePhone')), type: 'Phone'
    add_profile_field :mobile, value: phone_format(d('mobile')), type: 'Phone'
    add_profile_field :home_fax, value: phone_format(d('epdpersonalfax')), type: 'Phone'
    add_profile_field :work_phone, value: phone_format(d('epdprofphone')), type: 'Phone'
    add_profile_field :work_fax, value: phone_format(d('epdproffax')), type: 'Phone'

    add_profile_field :homepage, value: d('epdpersonallabeledurl'), type: 'Homepage'
    add_profile_field :work_homepage, value: d('epdproflabeledurl'), type: 'Homepage'

#    add_profile_field :employment, { type: 'Employment' }.merge(employment)
    professional_categories.each do |category|
      add_profile_field :professional_category, value: category, type: 'ProfessionCategory'
    end
    occupational_areas.each do |area|
      add_profile_field :occupational_area, value: area, type: 'ProfessionCategory'
    end
    add_profile_field :employment_status, value: d('epdprofworktype'), type: 'ProfessionCategory'

    @profile_fields
  end
  
  def add_profile_field( label, args )
    handle_existing_profile_field(label, args) do
      @profile_fields << args.merge( { label: label } ) if one_argument_present?(args)
    end
  end
  def one_argument_present?( args )
    args.except(:type).each do |key, value|
      return true if value.present?
    end
    return false
  end
  def profile_field_exists?( label, args )
    @profile_fields.include? args.merge( { label: label } )
  end
  def handle_existing_profile_field( label, args )
    # The update policy is handles outside this class. 
    # Here, we have just to make sure that the same profile field
    # is not created twice.
    #
    yield unless profile_field_exists?(label,args)
  end

  def phone_format( phone_number )
    ProfileFieldTypes::Phone.format_phone_number(phone_number) if phone_number
  end
  
  # TODO: WO EINFÜGEN?
  def contact_name
    
  end

  def home_address
    "#{d(:homePostalAddress)}\n" +
      "#{d(:epdpersonalpostalcode)} #{d(:epdpersonalcity)}\n" +
      "#{d(:epdcountry)}"
  end
  def home_address_label
    ( d('epdbuildingname') == "privat" ? nil : d('epdbuildingname') ) || :home_address
  end

  def professional_address
    "#{d(:epdprofaddress)}\n" +
      "#{d(:epdprofpostalcode)} #{d(:epdprofcity)}\n" +
      "#{d(:epdprofcountry)}"
  end
  def professional_address_label
    d('epdprofcompanyname') || ( aktiver? ? :study_address : :professional_address )
  end

#  def employment_title 
#    d("epdprofworktype").present? ? d("epdprofworktype") : 'employment'
#  end
#  def employment
#    { 
#      position: d("epdprofposition"),
#    }
#  end
  def professional_categories
    ( d('epdwingolfprofamtsbezeichnung') ? d('epdwingolfprofamtsbezeichnung') : "" ).split("|") + 
      ( d('epdprofposition') ? d('epdprofposition') : "" ).split("|")
  end

  def occupational_areas
    ( d('epdprofbusinesscateogory') ? d('epdprofbusinesscateogory') : "" ).split("|") +
      ( d('epdproffieldofemployment') ? d('epdproffieldofemployment') : "" ).split("|")
  end

  def bank_account
    {
      :account_holder => d('epdbankaccountowner'),
      :account_number => d('epdbankaccountnr'), 
      :bank_code => d('epdbankid'),
      :credit_institution => d('epdbankinstitution'), 
      :iban => d('epdbankiban'), 
      :bic => d('epdbankswiftcode') 
    }
  end

  def aktiver?
    d('epdorgstatusofperson') == "Aktiver"
  end
  def philister?
    d('epdorgstatusofperson') == "Philister"
  end
  def ehemaliger?
    d('epdorgstatusofperson') == "Ehemaliger"
  end

  def first_name
    d(:givenName)
  end
  def last_name
    d(:sn)
  end
  def name
    "#{first_name} #{last_name}"
  end

  def personal_title
    d('epdpersonaltitle') || d('epdpersonalothertitle')
  end
  def academic_titles
    (d('epdeduacademictitle') ? d('epdeduacademictitle') : "").split("|")
  end

  def uid
    d(:uid)
  end

  def email
    d(:mail)
  end
  def email=(email)
    @data_hash[:mail] = email
  end

  def date_of_birth
    begin
      d(:epdbirthdate).to_date
    rescue # wrong date format
      return nil
    end
  end

  def alias
    d(:epdalias)
  end
  def username
    self.alias
  end

  def academic_title
    d(:epdeduacademictitle)
  end

  def w_nummer
    d(:uid)
  end

  # status returns one of these strings:
  #   "Aktiver", "Philister", "Ehemaliger"
  #
  def status
    d(:epdorgstatusofperson)
  end

end



module UserImportMethods

  # The profile_fields_hash should look like this:
  #
  #   profile_fields_hash_array = [ { label: 'Work Address', value: "my work address...", type: "Address" },
  #                                 { label: 'Work Phone', value: "1234", type: "Phone" },
  #                                 { label: 'Bank Account', type: "BankAccount", account_number: "1234", iban: "567", ... },
  #                                 ... ]
  #
  def import_profile_fields( profile_fields_hash_array, update_policy )
    return nil if self.profile_fields.count > 0 && update_policy == :ignore
    self.profile_fields.destroy_all if update_policy == :replace
    profile_fields_hash_array.each do |profile_field_hash|
      unless profile_field_exists?(profile_field_hash)
        profile_field = self.profile_fields.build
        profile_field.import_attributes( profile_field_hash )
        profile_field.save
      end
    end
  end

  def profile_field_exists?( attrs )
    self.profile_fields.where( label: attrs[:label], value: attrs[:value] ).count > 0
  end

  def update_attributes( attrs )
    attrs.each do |key,value|
      self.send( "#{key}=", value )
    end
    self.save
  end

end

User.send( :include, UserImportMethods )

module ProfileFieldImportMethods

  # The attr_hash to import should look like this:
  #
  #   attr_hash = { label: ..., value: ..., type: ... }
  #
  # Types are:
  #
  #   Address, Email, Phone, Custom
  #
  def import_attributes( attr_hash )
    if attr_hash && attr_hash.kind_of?( Hash ) &&
        attr_hash[:label].present? && attr_hash[:type].present? &&
        attr_hash.keys.count > 2 # label, type, and some form of value

      unless attr_hash[:type].start_with? "ProfileFieldTypes::"
        attr_hash[:type] = "ProfileFieldTypes::#{attr_hash[:type]}"
      end

      self.update_attributes( type: attr_hash[:type] )
      self.save

      # This is needed in order to have access to the methods
      # that depend on the type set above.
      #
      reloaded_self = ProfileField.find(self.id)

      attr_hash.each do |key,value|
        reloaded_self.send("#{key}=", value)
      end
      reloaded_self.save

    end
  end

end

ProfileField.send( :include, ProfileFieldImportMethods )

