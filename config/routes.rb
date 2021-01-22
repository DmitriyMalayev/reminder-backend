Rails.application.routes.draw do
  resources :events   
  resources :calendars
  devise_for :users, path: "", path_names: {
    sign_in: "login",
    sign_out: "logout", 
    registration: "signup"
  }, 
  controllers: {
    sessions: "users/sessions", 
    registrations: "users/registrations"
  }
end



# # resources generates all 7 routes
# # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

# removing the path "" so we can remove routes starting with users and have it start with login logout and signup



#                                Prefix Verb   URI Pattern                                                                              Controller#Action
#                                events GET    /events(.:format)                                                                        events#index
#                                       POST   /events(.:format)                                                                        events#create
#                                 event GET    /events/:id(.:format)                                                                    events#show
#                                       PATCH  /events/:id(.:format)                                                                    events#update
#                                       PUT    /events/:id(.:format)                                                                    events#update
#                                       DELETE /events/:id(.:format)                                                                    events#destroy
#                             calendars GET    /calendars(.:format)                                                                     calendars#index
#                                       POST   /calendars(.:format)                                                                     calendars#create
#                              calendar GET    /calendars/:id(.:format)                                                                 calendars#show
#                                       PATCH  /calendars/:id(.:format)                                                                 calendars#update
#                                       PUT    /calendars/:id(.:format)                                                                 calendars#update
#                                       DELETE /calendars/:id(.:format)                                                                 calendars#destroy
#                      new_user_session GET    /login(.:format)                                                                         users/sessions#new
#                          user_session POST   /login(.:format)                                                                         users/sessions#create
#                  destroy_user_session DELETE /logout(.:format)                                                                        users/sessions#destroy
#                     new_user_password GET    /password/new(.:format)                                                                  devise/passwords#new
#                    edit_user_password GET    /password/edit(.:format)                                                                 devise/passwords#edit
#                         user_password PATCH  /password(.:format)                                                                      devise/passwords#update
#                                       PUT    /password(.:format)                                                                      devise/passwords#update
#                                       POST   /password(.:format)                                                                      devise/passwords#create
#              cancel_user_registration GET    /signup/cancel(.:format)                                                                 users/registrations#cancel
#                 new_user_registration GET    /signup/sign_up(.:format)                                                                users/registrations#new
#                edit_user_registration GET    /signup/edit(.:format)                                                                   users/registrations#edit
#                     user_registration PATCH  /signup(.:format)                                                                        users/registrations#update
#                                       PUT    /signup(.:format)                                                                        users/registrations#update
#                                       DELETE /signup(.:format)                                                                        users/registrations#destroy
#                                       POST   /signup(.:format)                                                                        users/registrations#create

#         rails_postmark_inbound_emails POST   /rails/action_mailbox/postmark/inbound_emails(.:format)                                  action_mailbox/ingresses/postmark/inbound_emails#create
#            rails_relay_inbound_emails POST   /rails/action_mailbox/relay/inbound_emails(.:format)                                     action_mailbox/ingresses/relay/inbound_emails#create
#         rails_sendgrid_inbound_emails POST   /rails/action_mailbox/sendgrid/inbound_emails(.:format)                                  action_mailbox/ingresses/sendgrid/inbound_emails#create
#   rails_mandrill_inbound_health_check GET    /rails/action_mailbox/mandrill/inbound_emails(.:format)                                  action_mailbox/ingresses/mandrill/inbound_emails#health_check
#         rails_mandrill_inbound_emails POST   /rails/action_mailbox/mandrill/inbound_emails(.:format)                                  action_mailbox/ingresses/mandrill/inbound_emails#create
#          rails_mailgun_inbound_emails POST   /rails/action_mailbox/mailgun/inbound_emails/mime(.:format)                              action_mailbox/ingresses/mailgun/inbound_emails#create
#        rails_conductor_inbound_emails GET    /rails/conductor/action_mailbox/inbound_emails(.:format)                                 rails/conductor/action_mailbox/inbound_emails#index
#                                       POST   /rails/conductor/action_mailbox/inbound_emails(.:format)                                 rails/conductor/action_mailbox/inbound_emails#create
#         rails_conductor_inbound_email GET    /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                             rails/conductor/action_mailbox/inbound_emails#show
#                                       PATCH  /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                             rails/conductor/action_mailbox/inbound_emails#update
#                                       PUT    /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                             rails/conductor/action_mailbox/inbound_emails#update
#                                       DELETE /rails/conductor/action_mailbox/inbound_emails/:id(.:format)                             rails/conductor/action_mailbox/inbound_emails#destroy
# rails_conductor_inbound_email_reroute POST   /rails/conductor/action_mailbox/:inbound_email_id/reroute(.:format)                      rails/conductor/action_mailbox/reroutes#create
#                    rails_service_blob GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                               active_storage/blobs#show
#             rails_blob_representation GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations#show
#                    rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                              active_storage/disk#show
#             update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                      active_storage/disk#update
#                  rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                           active_storage/direct_uploads#create