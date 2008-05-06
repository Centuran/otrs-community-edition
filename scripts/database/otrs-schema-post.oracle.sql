-- ----------------------------------------------------------
--  driver: oracle, generated: 2008-05-07 00:18:08
-- ----------------------------------------------------------
SET DEFINE OFF;
ALTER TABLE valid ADD CONSTRAINT FK_valid_create_by_id FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE valid ADD CONSTRAINT FK_valid_change_by_id FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE ticket_priority ADD CONSTRAINT FK_ticket_priority_create_by7c FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE ticket_priority ADD CONSTRAINT FK_ticket_priority_change_byd5 FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE ticket_type ADD CONSTRAINT FK_ticket_type_create_by_id FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE ticket_type ADD CONSTRAINT FK_ticket_type_change_by_id FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE ticket_type ADD CONSTRAINT FK_ticket_type_valid_id_id FOREIGN KEY (valid_id) REFERENCES valid(id);
ALTER TABLE ticket_lock_type ADD CONSTRAINT FK_ticket_lock_type_create_bf9 FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE ticket_lock_type ADD CONSTRAINT FK_ticket_lock_type_change_b8f FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE ticket_lock_type ADD CONSTRAINT FK_ticket_lock_type_valid_id71 FOREIGN KEY (valid_id) REFERENCES valid(id);
ALTER TABLE system_user ADD CONSTRAINT FK_system_user_create_by_id FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE system_user ADD CONSTRAINT FK_system_user_change_by_id FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE system_user ADD CONSTRAINT FK_system_user_valid_id_id FOREIGN KEY (valid_id) REFERENCES valid(id);
ALTER TABLE user_preferences ADD CONSTRAINT FK_user_preferences_user_id_id FOREIGN KEY (user_id) REFERENCES system_user(id);
ALTER TABLE groups ADD CONSTRAINT FK_groups_create_by_id FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE groups ADD CONSTRAINT FK_groups_change_by_id FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE groups ADD CONSTRAINT FK_groups_valid_id_id FOREIGN KEY (valid_id) REFERENCES valid(id);
ALTER TABLE group_user ADD CONSTRAINT FK_group_user_group_id_id FOREIGN KEY (group_id) REFERENCES groups(id);
ALTER TABLE group_user ADD CONSTRAINT FK_group_user_create_by_id FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE group_user ADD CONSTRAINT FK_group_user_change_by_id FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE group_user ADD CONSTRAINT FK_group_user_user_id_id FOREIGN KEY (user_id) REFERENCES system_user(id);
ALTER TABLE group_role ADD CONSTRAINT FK_group_role_group_id_id FOREIGN KEY (group_id) REFERENCES groups(id);
ALTER TABLE group_role ADD CONSTRAINT FK_group_role_role_id_id FOREIGN KEY (role_id) REFERENCES roles(id);
ALTER TABLE group_role ADD CONSTRAINT FK_group_role_create_by_id FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE group_role ADD CONSTRAINT FK_group_role_change_by_id FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE group_customer_user ADD CONSTRAINT FK_group_customer_user_groupbd FOREIGN KEY (group_id) REFERENCES groups(id);
ALTER TABLE group_customer_user ADD CONSTRAINT FK_group_customer_user_creat39 FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE group_customer_user ADD CONSTRAINT FK_group_customer_user_chang96 FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE roles ADD CONSTRAINT FK_roles_create_by_id FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE roles ADD CONSTRAINT FK_roles_change_by_id FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE roles ADD CONSTRAINT FK_roles_valid_id_id FOREIGN KEY (valid_id) REFERENCES valid(id);
ALTER TABLE role_user ADD CONSTRAINT FK_role_user_create_by_id FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE role_user ADD CONSTRAINT FK_role_user_change_by_id FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE role_user ADD CONSTRAINT FK_role_user_user_id_id FOREIGN KEY (user_id) REFERENCES system_user(id);
ALTER TABLE personal_queues ADD CONSTRAINT FK_personal_queues_queue_id_id FOREIGN KEY (queue_id) REFERENCES queue(id);
ALTER TABLE personal_queues ADD CONSTRAINT FK_personal_queues_user_id_id FOREIGN KEY (user_id) REFERENCES system_user(id);
ALTER TABLE theme ADD CONSTRAINT FK_theme_create_by_id FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE theme ADD CONSTRAINT FK_theme_change_by_id FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE theme ADD CONSTRAINT FK_theme_valid_id_id FOREIGN KEY (valid_id) REFERENCES valid(id);
ALTER TABLE ticket_state ADD CONSTRAINT FK_ticket_state_create_by_id FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE ticket_state ADD CONSTRAINT FK_ticket_state_change_by_id FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE ticket_state ADD CONSTRAINT FK_ticket_state_type_id_id FOREIGN KEY (type_id) REFERENCES ticket_state_type(id);
ALTER TABLE ticket_state ADD CONSTRAINT FK_ticket_state_valid_id_id FOREIGN KEY (valid_id) REFERENCES valid(id);
ALTER TABLE ticket_state_type ADD CONSTRAINT FK_ticket_state_type_create_ef FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE ticket_state_type ADD CONSTRAINT FK_ticket_state_type_change_da FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE salutation ADD CONSTRAINT FK_salutation_create_by_id FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE salutation ADD CONSTRAINT FK_salutation_change_by_id FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE salutation ADD CONSTRAINT FK_salutation_valid_id_id FOREIGN KEY (valid_id) REFERENCES valid(id);
ALTER TABLE signature ADD CONSTRAINT FK_signature_create_by_id FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE signature ADD CONSTRAINT FK_signature_change_by_id FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE signature ADD CONSTRAINT FK_signature_valid_id_id FOREIGN KEY (valid_id) REFERENCES valid(id);
ALTER TABLE system_address ADD CONSTRAINT FK_system_address_create_by_id FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE system_address ADD CONSTRAINT FK_system_address_change_by_id FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE system_address ADD CONSTRAINT FK_system_address_valid_id_id FOREIGN KEY (valid_id) REFERENCES valid(id);
ALTER TABLE follow_up_possible ADD CONSTRAINT FK_follow_up_possible_createe4 FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE follow_up_possible ADD CONSTRAINT FK_follow_up_possible_change6c FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE follow_up_possible ADD CONSTRAINT FK_follow_up_possible_valid_97 FOREIGN KEY (valid_id) REFERENCES valid(id);
ALTER TABLE queue ADD CONSTRAINT FK_queue_follow_up_id_id FOREIGN KEY (follow_up_id) REFERENCES follow_up_possible(id);
ALTER TABLE queue ADD CONSTRAINT FK_queue_group_id_id FOREIGN KEY (group_id) REFERENCES groups(id);
ALTER TABLE queue ADD CONSTRAINT FK_queue_salutation_id_id FOREIGN KEY (salutation_id) REFERENCES salutation(id);
ALTER TABLE queue ADD CONSTRAINT FK_queue_signature_id_id FOREIGN KEY (signature_id) REFERENCES signature(id);
ALTER TABLE queue ADD CONSTRAINT FK_queue_system_address_id_id FOREIGN KEY (system_address_id) REFERENCES system_address(id);
ALTER TABLE queue ADD CONSTRAINT FK_queue_create_by_id FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE queue ADD CONSTRAINT FK_queue_change_by_id FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE queue ADD CONSTRAINT FK_queue_valid_id_id FOREIGN KEY (valid_id) REFERENCES valid(id);
ALTER TABLE queue_preferences ADD CONSTRAINT FK_queue_preferences_queue_id4 FOREIGN KEY (queue_id) REFERENCES queue(id);
ALTER TABLE ticket ADD CONSTRAINT FK_ticket_queue_id_id FOREIGN KEY (queue_id) REFERENCES queue(id);
ALTER TABLE ticket ADD CONSTRAINT FK_ticket_service_id_id FOREIGN KEY (service_id) REFERENCES service(id);
ALTER TABLE ticket ADD CONSTRAINT FK_ticket_sla_id_id FOREIGN KEY (sla_id) REFERENCES sla(id);
ALTER TABLE ticket ADD CONSTRAINT FK_ticket_create_by_id FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE ticket ADD CONSTRAINT FK_ticket_change_by_id FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE ticket ADD CONSTRAINT FK_ticket_user_id_id FOREIGN KEY (user_id) REFERENCES system_user(id);
ALTER TABLE ticket ADD CONSTRAINT FK_ticket_responsible_user_id9 FOREIGN KEY (responsible_user_id) REFERENCES system_user(id);
ALTER TABLE ticket ADD CONSTRAINT FK_ticket_ticket_lock_id_id FOREIGN KEY (ticket_lock_id) REFERENCES ticket_lock_type(id);
ALTER TABLE ticket ADD CONSTRAINT FK_ticket_ticket_priority_id84 FOREIGN KEY (ticket_priority_id) REFERENCES ticket_priority(id);
ALTER TABLE ticket ADD CONSTRAINT FK_ticket_ticket_state_id_id FOREIGN KEY (ticket_state_id) REFERENCES ticket_state(id);
ALTER TABLE ticket ADD CONSTRAINT FK_ticket_type_id_id FOREIGN KEY (type_id) REFERENCES ticket_type(id);
ALTER TABLE ticket ADD CONSTRAINT FK_ticket_valid_id_id FOREIGN KEY (valid_id) REFERENCES valid(id);
ALTER TABLE ticket_history ADD CONSTRAINT FK_ticket_history_article_id3c FOREIGN KEY (article_id) REFERENCES article(id);
ALTER TABLE ticket_history ADD CONSTRAINT FK_ticket_history_queue_id_id FOREIGN KEY (queue_id) REFERENCES queue(id);
ALTER TABLE ticket_history ADD CONSTRAINT FK_ticket_history_owner_id_id FOREIGN KEY (owner_id) REFERENCES system_user(id);
ALTER TABLE ticket_history ADD CONSTRAINT FK_ticket_history_create_by_id FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE ticket_history ADD CONSTRAINT FK_ticket_history_change_by_id FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE ticket_history ADD CONSTRAINT FK_ticket_history_ticket_id_id FOREIGN KEY (ticket_id) REFERENCES ticket(id);
ALTER TABLE ticket_history ADD CONSTRAINT FK_ticket_history_history_ty49 FOREIGN KEY (history_type_id) REFERENCES ticket_history_type(id);
ALTER TABLE ticket_history ADD CONSTRAINT FK_ticket_history_priority_i5c FOREIGN KEY (priority_id) REFERENCES ticket_priority(id);
ALTER TABLE ticket_history ADD CONSTRAINT FK_ticket_history_state_id_id FOREIGN KEY (state_id) REFERENCES ticket_state(id);
ALTER TABLE ticket_history ADD CONSTRAINT FK_ticket_history_type_id_id FOREIGN KEY (type_id) REFERENCES ticket_type(id);
ALTER TABLE ticket_history ADD CONSTRAINT FK_ticket_history_valid_id_id FOREIGN KEY (valid_id) REFERENCES valid(id);
ALTER TABLE ticket_history_type ADD CONSTRAINT FK_ticket_history_type_creat46 FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE ticket_history_type ADD CONSTRAINT FK_ticket_history_type_chang79 FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE ticket_history_type ADD CONSTRAINT FK_ticket_history_type_valid1c FOREIGN KEY (valid_id) REFERENCES valid(id);
ALTER TABLE article_type ADD CONSTRAINT FK_article_type_create_by_id FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE article_type ADD CONSTRAINT FK_article_type_change_by_id FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE article_type ADD CONSTRAINT FK_article_type_valid_id_id FOREIGN KEY (valid_id) REFERENCES valid(id);
ALTER TABLE article_sender_type ADD CONSTRAINT FK_article_sender_type_creat12 FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE article_sender_type ADD CONSTRAINT FK_article_sender_type_changbd FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE article_sender_type ADD CONSTRAINT FK_article_sender_type_validba FOREIGN KEY (valid_id) REFERENCES valid(id);
ALTER TABLE article_flag ADD CONSTRAINT FK_article_flag_create_by_id FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE article ADD CONSTRAINT FK_article_article_sender_ty21 FOREIGN KEY (article_sender_type_id) REFERENCES article_sender_type(id);
ALTER TABLE article ADD CONSTRAINT FK_article_article_type_id_id FOREIGN KEY (article_type_id) REFERENCES article_type(id);
ALTER TABLE article ADD CONSTRAINT FK_article_create_by_id FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE article ADD CONSTRAINT FK_article_change_by_id FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE article ADD CONSTRAINT FK_article_ticket_id_id FOREIGN KEY (ticket_id) REFERENCES ticket(id);
ALTER TABLE article ADD CONSTRAINT FK_article_valid_id_id FOREIGN KEY (valid_id) REFERENCES valid(id);
ALTER TABLE article_plain ADD CONSTRAINT FK_article_plain_article_id_id FOREIGN KEY (article_id) REFERENCES article(id);
ALTER TABLE article_plain ADD CONSTRAINT FK_article_plain_create_by_id FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE article_plain ADD CONSTRAINT FK_article_plain_change_by_id FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE article_attachment ADD CONSTRAINT FK_article_attachment_articlc6 FOREIGN KEY (article_id) REFERENCES article(id);
ALTER TABLE article_attachment ADD CONSTRAINT FK_article_attachment_create4f FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE article_attachment ADD CONSTRAINT FK_article_attachment_change57 FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE standard_response ADD CONSTRAINT FK_standard_response_create_2a FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE standard_response ADD CONSTRAINT FK_standard_response_change_a4 FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE standard_response ADD CONSTRAINT FK_standard_response_valid_ifd FOREIGN KEY (valid_id) REFERENCES valid(id);
ALTER TABLE queue_standard_response ADD CONSTRAINT FK_queue_standard_response_q47 FOREIGN KEY (queue_id) REFERENCES queue(id);
ALTER TABLE queue_standard_response ADD CONSTRAINT FK_queue_standard_response_s28 FOREIGN KEY (standard_response_id) REFERENCES standard_response(id);
ALTER TABLE queue_standard_response ADD CONSTRAINT FK_queue_standard_response_c18 FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE queue_standard_response ADD CONSTRAINT FK_queue_standard_response_c33 FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE standard_attachment ADD CONSTRAINT FK_standard_attachment_creat30 FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE standard_attachment ADD CONSTRAINT FK_standard_attachment_changb9 FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE standard_attachment ADD CONSTRAINT FK_standard_attachment_valid6d FOREIGN KEY (valid_id) REFERENCES valid(id);
ALTER TABLE standard_response_attachment ADD CONSTRAINT FK_standard_response_attachm3c FOREIGN KEY (standard_attachment_id) REFERENCES standard_attachment(id);
ALTER TABLE standard_response_attachment ADD CONSTRAINT FK_standard_response_attachmb6 FOREIGN KEY (standard_response_id) REFERENCES standard_response(id);
ALTER TABLE standard_response_attachment ADD CONSTRAINT FK_standard_response_attachmee FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE standard_response_attachment ADD CONSTRAINT FK_standard_response_attachmfb FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE auto_response_type ADD CONSTRAINT FK_auto_response_type_create9b FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE auto_response_type ADD CONSTRAINT FK_auto_response_type_change4c FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE auto_response_type ADD CONSTRAINT FK_auto_response_type_valid_7b FOREIGN KEY (valid_id) REFERENCES valid(id);
ALTER TABLE auto_response ADD CONSTRAINT FK_auto_response_type_id_id FOREIGN KEY (type_id) REFERENCES auto_response_type(id);
ALTER TABLE auto_response ADD CONSTRAINT FK_auto_response_system_addrd5 FOREIGN KEY (system_address_id) REFERENCES system_address(id);
ALTER TABLE auto_response ADD CONSTRAINT FK_auto_response_create_by_id FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE auto_response ADD CONSTRAINT FK_auto_response_change_by_id FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE auto_response ADD CONSTRAINT FK_auto_response_valid_id_id FOREIGN KEY (valid_id) REFERENCES valid(id);
ALTER TABLE queue_auto_response ADD CONSTRAINT FK_queue_auto_response_auto_cd FOREIGN KEY (auto_response_id) REFERENCES auto_response(id);
ALTER TABLE queue_auto_response ADD CONSTRAINT FK_queue_auto_response_queue42 FOREIGN KEY (queue_id) REFERENCES queue(id);
ALTER TABLE queue_auto_response ADD CONSTRAINT FK_queue_auto_response_creat3d FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE queue_auto_response ADD CONSTRAINT FK_queue_auto_response_chang7f FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE time_accounting ADD CONSTRAINT FK_time_accounting_article_i98 FOREIGN KEY (article_id) REFERENCES article(id);
ALTER TABLE time_accounting ADD CONSTRAINT FK_time_accounting_create_byb3 FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE time_accounting ADD CONSTRAINT FK_time_accounting_change_byf3 FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE time_accounting ADD CONSTRAINT FK_time_accounting_ticket_id91 FOREIGN KEY (ticket_id) REFERENCES ticket(id);
ALTER TABLE ticket_watcher ADD CONSTRAINT FK_ticket_watcher_user_id_id FOREIGN KEY (user_id) REFERENCES system_user(id);
ALTER TABLE ticket_watcher ADD CONSTRAINT FK_ticket_watcher_create_by_id FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE ticket_watcher ADD CONSTRAINT FK_ticket_watcher_change_by_id FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE ticket_watcher ADD CONSTRAINT FK_ticket_watcher_ticket_id_id FOREIGN KEY (ticket_id) REFERENCES ticket(id);
ALTER TABLE service ADD CONSTRAINT FK_service_create_by_id FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE service ADD CONSTRAINT FK_service_change_by_id FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE service_customer_user ADD CONSTRAINT FK_service_customer_user_ser04 FOREIGN KEY (service_id) REFERENCES service(id);
ALTER TABLE service_customer_user ADD CONSTRAINT FK_service_customer_user_credd FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE sla ADD CONSTRAINT FK_sla_service_id_id FOREIGN KEY (service_id) REFERENCES service(id);
ALTER TABLE sla ADD CONSTRAINT FK_sla_create_by_id FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE sla ADD CONSTRAINT FK_sla_change_by_id FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE ticket_index ADD CONSTRAINT FK_ticket_index_group_id_id FOREIGN KEY (group_id) REFERENCES groups(id);
ALTER TABLE ticket_index ADD CONSTRAINT FK_ticket_index_queue_id_id FOREIGN KEY (queue_id) REFERENCES queue(id);
ALTER TABLE ticket_index ADD CONSTRAINT FK_ticket_index_ticket_id_id FOREIGN KEY (ticket_id) REFERENCES ticket(id);
ALTER TABLE ticket_lock_index ADD CONSTRAINT FK_ticket_lock_index_ticket_89 FOREIGN KEY (ticket_id) REFERENCES ticket(id);
ALTER TABLE customer_user ADD CONSTRAINT FK_customer_user_create_by_id FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE customer_user ADD CONSTRAINT FK_customer_user_change_by_id FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE customer_user ADD CONSTRAINT FK_customer_user_valid_id_id FOREIGN KEY (valid_id) REFERENCES valid(id);
ALTER TABLE mail_account ADD CONSTRAINT FK_mail_account_create_by_id FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE mail_account ADD CONSTRAINT FK_mail_account_change_by_id FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE mail_account ADD CONSTRAINT FK_mail_account_valid_id_id FOREIGN KEY (valid_id) REFERENCES valid(id);
ALTER TABLE notifications ADD CONSTRAINT FK_notifications_create_by_id FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE notifications ADD CONSTRAINT FK_notifications_change_by_id FOREIGN KEY (change_by) REFERENCES system_user(id);
ALTER TABLE package_repository ADD CONSTRAINT FK_package_repository_createa7 FOREIGN KEY (create_by) REFERENCES system_user(id);
ALTER TABLE package_repository ADD CONSTRAINT FK_package_repository_changea6 FOREIGN KEY (change_by) REFERENCES system_user(id);
