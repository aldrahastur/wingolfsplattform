require 'spec_helper'

describe HorizontalNav do
  
  before do
    @user = create :user
    @corporation_a = create :wingolf_corporation
    @corporation_b = create :wingolf_corporation
    @bv = create :bv_group
    
    @horizontal_nav = HorizontalNav.new(user: @user, current_navable: Page.find_intranet_root)
  end

  describe "#navables" do
    subject { @horizontal_nav.navables }
    
    it { should include Page.find_intranet_root }
  
    describe "for the user being member of one corporation" do
      before { @corporation_a.status_group("Hospitanten") << @user }
      it { should include @corporation_a }
    end
    
    describe "for the user being member of several corporations" do
      before do
        @corporation_a.status_group("Philister") << @user
        @corporation_b.status_group("Philister") << @user
      end
      it "should include all corporations" do
        subject.should include @corporation_a
        subject.should include @corporation_b
      end
    end
    
    describe "for the user being former member of a corporation" do
      before do
        @corporation_a.status_group("Philister") << @user
        @membership = @corporation_b.status_group("Philister").assign_user @user, at: 1.hour.ago
        @membership.move_to @corporation_b.status_group("Schlicht Ausgetretene")
        time_travel 2.seconds
      end
      it "should include the corporations the user is still member in" do
        subject.should include @corporation_a
      end
      it "should not include the former corporations" do
        subject.should_not include @corporation_b
      end
    end
    
    describe "for the user being member of a bv" do
      before { @bv.assign_user @user, at: 1.hour.ago; @user.reload }
      it { should include @bv }
    end
  end
end

