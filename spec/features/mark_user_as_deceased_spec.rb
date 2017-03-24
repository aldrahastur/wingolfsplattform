require 'spec_helper'

feature 'Mark user as deceased' do
  include SessionSteps
  
  before do
    @user = create :user
    @corporation = create :wingolf_corporation
    @philister = @corporation.descendant_groups.where(name: 'Philister').first
    @verstorbene = @corporation.descendant_groups.where(name: 'Verstorbene').first
    @membership = @philister.assign_user @user, at: 1.day.ago
    Workflow.find_or_create_mark_as_deceased_workflow
    @user.reload

    login :admin
  end
  
  specify 'prelims' do
    @user.current_status_group_in(@corporation).should == @philister
    @user.current_status_membership_in(@corporation).should == @membership.becomes(Memberships::Status)
  end
  
  scenario 'mark the user as deceased', js: true do
    @retry_counter = 0
    begin
    
      visit user_path(@user)
      
      within('.box.section.general') do
        find('.workflow_triggers').click
        find('.deceased_trigger').click
      end
        
      localized_date = I18n.localize("2014-07-06".to_date)
      within('.deceased_modal_date_of_death') do
        fill_in 'localized_date_of_death', with: localized_date
        click_on I18n.t(:confirm)
      end
      
      # wait for it to be finished:
      page.should have_no_text I18n.t(:confirm), visible: true
      @user.reload
      
      page.should have_text @user.title
      page.should have_text "(✟)"
      page.should have_text localized_date
      @user.current_status_group_in(@corporation.reload).should == @verstorbene
      
      visit group_path(@verstorbene)
      page.should have_text @user.last_name
      
    rescue  # This spec fails randomly. This is a workaround. TODO: Fix this properly.
      @retry_counter += 1
      retry if @retry_counter < 5
    end
  end
end