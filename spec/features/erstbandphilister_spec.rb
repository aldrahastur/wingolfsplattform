require 'spec_helper'

feature "Erstbandphilister" do
  include SessionSteps

  before do
    @corporation = create :wingolf_corporation
    @philisterschaft_group = @corporation.philisterschaft
    @regular_philister_group = @corporation.status_group("Philister")
    @philisterschaft_group.create_erstbandphilister_parent_group
    @philister_user = create(:user_with_account)
    @regular_philister_group.assign_user @philister_user, at: 10.minutes.ago

    login(@philister_user)
  end
  
  specify 'requirements' do
    @corporation.descendant_groups.where(name: "Erstbandphilister").first.members.should include @philister_user
    @corporation.descendant_groups.where(name: "Erstbandphilister").first.memberships_for_member_list.count.should == 1
  end

  scenario "visit corporation site and navigate to the erstbandphilister site" do
    visit group_path(@corporation)
    within(".vertical_menu") { click_on "Philisterschaft" }
    within(".vertical_menu") { click_on "Erstbandphilister" }
    within('.group_tabs') { click_on I18n.t(:members) }
    within("#content_area") do
      page.should have_content "Erstbandphilister"
      page.should have_content @philister_user.last_name
      page.should have_content @philister_user.first_name
      page.should have_content @philister_user.aktivitätszahl
      @philister_user.title.length.should > 5
    end
  end

end
