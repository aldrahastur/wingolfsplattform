# This class helps to export data to CSV, XLS and possibly others.
#
# Example:
#
#     class PeopleController
#       def index
#         # ...
#         format.xls do
#           send_data ListExport.new(@people, :birthday_list).to_xls
#         end
#       end
#     end
#
# The following ressources might be helpful.
#
#   * https://github.com/splendeo/to_xls
#   * https://github.com/zdavatz/spreadsheet
#   * Formatting xls: http://scm.ywesee.com/?p=spreadsheet/.git;a=blob;f=lib/spreadsheet/format.rb
#   * to_xls gem example: http://stackoverflow.com/questions/15600987/rails-export-arbitrary-array-to-excel-using-to-xls-gem
# 
class ListExport
  attr_accessor :data, :preset, :csv_options
  
  def initialize(data, preset = nil)
    @data = data; @preset = preset
    @csv_options =  { col_sep: ';', quote_char: '"' }
    data = sorted_data
  end
  
  def columns
    case preset.to_s
    when 'birthday_list'
      [:last_name, :first_name, :cached_name_affix, :cached_localized_birthday_this_year, 
        :cached_localized_date_of_birth, :cached_current_age]
    when 'address_list'
      # TODO: Add the street as a separate column.
      # This was requested at the meeting at Gernsbach, Jun 2014.
      
      [:last_name, :first_name, :cached_name_affix, :cached_postal_address_with_name_surrounding,
        :cached_postal_address, :cached_localized_postal_address_updated_at, 
        :cached_postal_address_postal_code, :cached_postal_address_town,
        :cached_postal_address_country, :cached_postal_address_country_code,
        :cached_personal_title, :cached_address_label_text_above_name, :cached_address_label_text_below_name,
        :cached_address_label_text_before_name, :cached_address_label_text_after_name]
    when 'phone_list' then []
    when 'email_list' then []
    when 'member_development' then []
    else
      # This name_list is the default.
      [:last_name, :first_name, :cached_name_affix, :cached_personal_title, :cached_academic_degree]
    end
  end
  
  def headers
    columns.collect do |column| 
      I18n.translate column.to_s.gsub('cached_', '').gsub('localized_', '')
    end
  end
  
  def sorted_data
    case preset
    when 'birthday_list'
      data.sort_by do |user|
        user.cached_date_of_birth.try(:strftime, "%m-%d") || ''
      end
      
      # TODO: Restliche nach Nachnamen sortieren.
      
    else
      data
    end
  end
  
  def to_csv
    CSV.generate(csv_options) do |csv|
      csv << headers
      data.each do |row|
        csv << columns.collect { |column_name| row.try(:send, column_name) }
      end
    end
  end
  
  def to_xls
    data.to_xls(columns: columns, headers: headers, header_format: {weight: 'bold'})
  end
  
  def to_s
    to_csv
  end
end

require 'user'
class User
  def cached_current_age
    cached_age
  end
  def cached_localized_birthday_this_year
    I18n.localize cached_birthday_this_year
  end
  def cached_localized_date_of_birth
    I18n.localize cached_date_of_birth
  end
  def cached_postal_address_with_name_surrounding
    cached_address_label.postal_address_with_name_surrounding
  end
  def postal_address_updated_at
    # if the date is earlier, the date is actually the date
    # of the data migration and should not be shown.
    postal_address_field_or_first_address_field.updated_at.to_date if postal_address_field_or_first_address_field && postal_address_field_or_first_address_field.updated_at.to_date > "2014-02-28".to_date 
  end
  def cached_postal_address_updated_at
    Rails.cache.fetch(['User', id, 'postal_address_updated_at'], expires_in: 1.week) { postal_address_updated_at }
  end
  def cached_localized_postal_address_updated_at
    I18n.localize cached_postal_address_updated_at if cached_postal_address_updated_at
  end
  def cached_postal_address_postal_code
    cached_address_label.postal_code
  end
  def cached_postal_address_town
    Rails.cache.fetch(['User', id, 'postal_address_town'], expires_in: 1.week) do
      postal_address_field_or_first_address_field.geo_location.city if postal_address_field_or_first_address_field
    end
  end
  def cached_postal_address_country
    Rails.cache.fetch(['User', id, 'postal_address_country'], expires_in: 1.week) do
      postal_address_field_or_first_address_field.geo_location.country if postal_address_field_or_first_address_field
    end
  end
  def cached_postal_address_country_code
    cached_address_label.country_code
  end
  def cached_address_label_text_above_name
    cached_address_label.text_above_name
  end
  def cached_address_label_text_below_name
    cached_address_label.text_below_name
  end
  def cached_address_label_text_before_name
    cached_address_label.name_prefix
  end
  def cached_address_label_text_after_name
    cached_address_label.name_suffix
  end
end