require_dependency YourPlatform::Engine.root.join('app/models/profile_fields/address').to_s

module ProfileFields

  # Address Information
  #
  class Address

    # This method returns the Bv associated with the given address.
    #
    def bv
      Bv.find bv_id if bv_id
    end

    def bv_id
      Bv.by_address_field(self).try(:id)
    end

    # The html output method is overridden here, in order to display the bv as well.
    #
    def display_html
      text_to_display = self.value

      if self.bv
        text_to_display = "
        <p>#{text_to_display}</p>
        <p class=\"address_is_in_bv\">
          (#{I18n.translate( :address_is_in_the )} " +
          ActionController::Base.helpers.link_to( self.bv.name,
                                                  Rails.application.routes.url_helpers.group_path( self.bv.becomes( Group ) ) ) +
          ")
        </p>"

        # more infos on how to use the link_to helper in models:
        # http://stackoverflow.com/questions/4713571/view-helper-link-to-in-model-class
      end
      ActionController::Base.helpers.simple_format( text_to_display )
    end

    # Allow to mark the address as primary postal address.
    #
    def wingolfspost
      self.postal_address
    end
    def wingolfspost=(new_wingolfspost)
      self.postal_address = new_wingolfspost
      self.profileable.adapt_bv_to_primary_address
    end
    def wingolfspost?
      self.wingolfspost
    end

    cache :bv_id if use_caching?
  end

end
