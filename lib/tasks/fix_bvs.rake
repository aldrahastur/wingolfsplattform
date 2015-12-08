namespace :fix do

  task :bvs => [
    'bvs:fix_assignments'
  ]
  
  namespace :bvs do
    
    task :requirements do
      require 'importers/models/log'
    end
        
    task :print_info => [:requirements] do
      log.head "Fix BVs"
      log.info "Dieser Task führt Korrekturen bzgl. der Bezirksverbände durch."
      log.info ""
    end
    
    task :fix_assignments => [
      'environment',
      'requirements',
      'print_info',
      'assign_unassigned_philistres_to_bvs',
      'list_users_without_postal_address',
      'list_addresses_without_bv',
      'correct_bv_assignments_of_all_philistres'
    ]
    
    task :assign_unassigned_philistres_to_bvs => [:environment, :requirements, :print_info] do
      log.section "Philister ohne BV-Zugehörigkeit einem BV zuordnen"
      log.info "Alle Philister sollten einem Bezirksverband zugeordnet sein. Philister ohne"
      log.info "eine solche Zuordnung einem BV anhand ihrer Postanschrift zuordnen."
      log.info ""
      log.info "Dies betrifft #{alle_philister_ohne_bv.count} Philister."
      log.info "Diese werden nun einem BV zugeordnet:"
      log.info ""

      for user in alle_philister_ohne_bv
        if user.alive? and user.wingolfit?
          print "* (#{user.id}) #{user.w_nummer} #{user.title} ... "
          
          user.adapt_bv_to_postal_address
          
          if user && user.bv
            print "#{user.bv.token}\n"
          else
            if user.in? alle_benutzer_ohne_postanschrift
              log.warning "Keine Post-Anschrift!"
            else
              log.failure "konnte keinem BV zugeordnet werden. Kontrolle erforderlich!"
            end
          end
        end
      end
      
      log.success "Fertig."
    end
    
    task :remove_multiple_bv_assignments => [:environment, :requirements, :print_info] do
      log.section "BV-Doppel-Mitgliedschaften entfernen"
      log.info "Ein Philister soll genau einem BV zugeordnet sein. Dieser Task"
      log.info "entfernt eventuelle zusätzliche BV-Mitgliedschaften."
      log.info ""
      log.info "Das Betrifft #{alle_philister_mit_mehreren_bvs.count} Philister:"
      log.info ""

      for user in alle_philister_mit_mehreren_bvs
        print "* (#{user.id}) #{user.w_nummer} #{user.title} ... "
        
        correct_membership = user.adapt_bv_to_postal_address
        raise 'no membership' unless correct_membership.kind_of? UserGroupMembership
        
        if user.reload.bv
          log.info "#{user.reload.bv.token} ist korrekt."
        else
          log.failure "konnte keinem BV zugeordnet werden. Kontrolle erforderlich!"
        end
      end
    end
    
    task :list_users_without_postal_address => [:environment, :requirements, :print_info] do
      log.section "Wingolfiten ohne Postanschrift"
      log.info "Die folgenden Wingolfiten haben keine Postanschrift hinterlegt:"
      log.info ""
      
      for user in alle_benutzer_ohne_postanschrift
        if user.alive? and user.wingolfit?
          log.info "* (#{user.id}) #{user.w_nummer} #{user.title}"
        end
      end
    end
    
    task :list_addresses_without_bv => [:environment, :requirements, :print_info] do
      log.section "Adresse ohne BV-Zuordnung"
      log.info "Die folgenden Adressen können keinem BV zugeordnet werden."
      log.info ""
      log.info "Bitte fügen Sie entsprechende Zuordnungen mit Hilfe des Tasks"
      log.info "'rake import:bvs:additional_mappings' hinzu."
      log.info "Danach muss der Task 'rake fix:bvs' erneut ausgeführt werden.".yellow
      log.info ""
      
      for address_field in ProfileField.where(type: 'ProfileFieldTypes::Address')
        unless address_field.bv
          if address_field.plz
            address = address_field.value.gsub("\n", ", ")
            log.info "* PLZ #{address_field.plz} : #{address}"
          end
        end
      end
    end
    
    task :correct_bv_assignments_of_all_philistres => [:environment, :requirements, :print_info] do
      log.section "BV-Zuordnungen aller Philister überprüfen"
      log.info "Alle Philister werden nun durchgegangen und überprüft, ob der eingetragene"
      log.info "zur Anschrift für Wingolfspost passt. Falls nicht, wird die BV-Zuordnung"
      log.info "korrigiert und im Folgenden aufgelistet:"
      log.info ""
      
      for user in alle_philister.reorder(:id)
        
        # Nur, wenn kein Wunsch-BV # TODO
        # Oder, wenn im BV 00.
        
        user.delete_cached :bv
        if user.postal_address_field_or_first_address_field && (user.correct_bv != user.bv)
          log.info "* (#{user.id}) #{user.title}, wohnhaft in #{user.postal_address_field_or_first_address_field.plz} #{user.postal_address_field_or_first_address_field.city}: #{user.bv.try(:token)} -> #{user.correct_bv.try(:token)}"

          if user.bv == Bv.find_by_token("BV 00")
            if user.bv_membership.nil?
              log.error "    -> Kein bv_membership. DAG-Links fehlerhaft?"
            else
              
              begin
                user.adapt_bv_to_postal_address
              rescue ActiveRecord::ActiveRecordError
                log.error "    -> ActiveRecord::ActiveRecordError. DAG-Links fehlerhaft?"
              end
          
              user.delete_cached :bv
              if user.postal_address_field.bv != user.reload.bv
                log.warning "    -> BV-Neuzuordnung fehlgeschlagen. Bitte manuell überprüfen."
              end
            end
          else
            log.warning "    -> BV-Neuzuordnung nicht vorgenommen, da derzeit nicht im BV 00. Bitte händisch prüfen, ob es sich um einen Wunsch-BV-Philister handelt."
          end
        end
      end
      log.success "Fertig."
    end
    
  end
  
  def log
    $log ||= Log.new
  end
  
  def alle_philister
    (Group.where(name: "Alle Philister").first || raise('Gruppe "Alle Philister" nicht gefunden.')).members
  end
  
  def alle_bv_philister
    User.joins_groups.where(:groups => {name: "Bezirksverbände"}).uniq
  end
  
  def alle_philister_mit_mehreren_bvs
    bv_ids = Bv.pluck(:id)
    bv_users = User.joins_groups.where(:groups => {id: bv_ids})
    users_in_multiple_bvs = bv_users - bv_users.uniq
    return users_in_multiple_bvs
  end

  def alle_philister_ohne_bv
    alle_philister - alle_bv_philister - [nil]
  end
  
  def alle_benutzer_ohne_postanschrift
    User.without_postal_address
  end
  
  def alle_benutzer_mit_postanschrift
    User.with_postal_address
  end
  
end

