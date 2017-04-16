require 'spec_helper'

feature 'Change Password', :js => true do
  include SessionSteps

  subject { page }

  describe 'when visiting the own profile' do
    background do
      @user = create(:user_with_account)
      @current_password = @user.account.password
      login(@user)
      visit user_path(@user)
      within('.box.section.access') do
        click_on I18n.t(:edit)
      end
    end

    it { should have_link I18n.t(:change_password) }

    describe "and clicking #{I18n.t(:change_password)}" do
      background do
        #
        # Currently, we experience an issue with the edge version of turbolinks:
        #
        #     TypeError: 'undefined' is not an object (evaluating 'currentState.url')
        #     TypeError: 'undefined' is not an object (evaluating 'currentState.url')
        #         at http://127.0.0.1:61891/assets/application.js:64080
        #         at http://127.0.0.1:61891/assets/application.js:63963
        #         at http://127.0.0.1:61891/assets/application.js:64566 in Click
        #         at http://127.0.0.1:61891/assets/application.js:64555
        #
        # This does only occur in the specs, not when run in the browser.
        # Threfore, we circumvent turbolinks at this point in this spec.
        #
        # # click_on I18n.t(:change_password)
        #
        # TODO: Revert back to `click_on I18n.t(:change_password)` when updating turbolinks
        # to the 3.0 release.
        #
        visit change_password_path
      end

      it { should have_field('user_account_password') }
      it { should have_field('user_account_password_confirmation') }
      it { should have_field('user_account_current_password') }
      it { should have_field(I18n.t(:i_agree_i_do_not_use_the_same_password_on_other_services), :checked => false) }
      it { should have_button(I18n.t(:submit_changed_password), visible: false) }

      describe 'and matching complex password and confirmation' do
        before do
          @password = 'fordprefecthasanawesometowel!'
          fill_in 'user_account_password', with: @password
          fill_in 'user_account_password_confirmation', with: @password
        end

        describe 'and correct current password' do
          before do
            fill_in 'user_account_current_password', with: @current_password
          end

          describe 'and having checked the agreement' do
            before do
              check(I18n.t(:i_agree_i_do_not_use_the_same_password_on_other_services))
            end

            it { should have_button(I18n.t('submit_changed_password')) }

            describe '- after clicking submit'do
              before do
                click_button I18n.t(:submit_changed_password)
              end
              it { should have_notice(I18n.t('devise.registrations.updated')) }
            end

          end

          describe 'but not having checked the agreement' do
            it { should have_button(I18n.t('submit_changed_password'), visible: false) }
          end
        end

        describe 'but wrong current password' do
          before do
            fill_in 'user_account_current_password', with: 'invalid'
          end

          it { should have_button(I18n.t('submit_changed_password'), visible: false) }
        end

      end

      describe 'and matching simple password and confirmation' do
        before do
          @password = 'Password123'
          fill_in 'user_account_password', with: @password
          fill_in 'user_account_password_confirmation', with: @password
          fill_in 'user_account_current_password', with: @current_password
          check(I18n.t(:i_agree_i_do_not_use_the_same_password_on_other_services))
        end

        it { should have_no_notice(I18n.t('devise.registrations.updated')) }
        it { should have_button(I18n.t('submit_changed_password'), visible: false) }

      end

      describe 'but without matching password confirmation' do
        before do
          @password = 'fordprefecthasanawesometowel!'
          fill_in 'user_account_password', with: @password
          fill_in 'user_account_password_confirmation', with: 'invalid'
          fill_in 'user_account_current_password', with: @current_password
        end

        it { should have_button(I18n.t('submit_changed_password'), visible: false) }
      end

    end

  end

  describe 'when visiting the profile of another user' do
    background do
      @user = create(:user_with_account)
      login(:user)
      visit user_path(@user)
    end

    it { should_not have_link(I18n.t(:change_password))}
  end

  describe 'when visiting the profile of another user as admin' do
    background do
      @user = create(:user_with_account)
      login(:admin)
      visit user_path(@user)
    end

    it { should_not have_link(I18n.t(:change_password))}
  end
end