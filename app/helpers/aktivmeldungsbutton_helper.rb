module AktivmeldungsbuttonHelper

  def aktivmeldungsbutton
    if show_aktivmeldungsbutton?
      corporation_id = @navable.corporation.id if @navable.kind_of?(Group) && @navable.corporation
      link_to( t(:enter_aktivmeldung), new_aktivmeldung_path(group_id: corporation_id), :class => "btn btn-success")
    end
  end

  def show_aktivmeldungsbutton?
    current_user_has_necessary_permissions? and not currently_showing_the_form_for_aktivmeldung?
  end

  private

  def current_user_has_necessary_permissions?
    can? :create, User
  end

  def currently_showing_the_form_for_aktivmeldung?
    params[:controller] == "users" && params[:action] == "new"
  end

end
