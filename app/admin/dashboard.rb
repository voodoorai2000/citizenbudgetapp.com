# coding: utf-8
ActiveAdmin.register_page 'Dashboard' do
  controller.before_filter :set_locale
  menu priority: 1, label: proc{ I18n.t :dashboard }

  content title: proc{ I18n.t :dashboard } do
    render 'index'
  end
end
