require_dependency YourPlatform::Engine.root.join('app/models/list_exports/list_export_user').to_s

module ListExports
  class ListExportUser
    
    def cached_bv_name
      bv.try(:name)
    end

    def bv_token
      bv.try(:token)
    end

    def cached_bv_token
      bv.try(:token)
    end
    
    def last_bv_name
      self.memberships.with_past.where(ancestor_type: 'Group', ancestor_id: Bv.pluck(:id)).order(:valid_from).last.try(:group).try(:token)
    end
    
    def im_bv_seit
      I18n.localize bv_beitrittsdatum.to_date if bv_beitrittsdatum
    end
    
  end
end