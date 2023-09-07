--Ensure Database Mail is installed
EXEC msdb.dbo.sysmail_help_configure_sp;

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Database Mail XPs', 1;
RECONFIGURE;


--Configure Database Mail
EXEC msdb.dbo.sysmail_add_account_sp
  @account_name = 'GmailAccount',
  @email_address = 'your_email@gmail.com',
  @display_name = 'Your Name',
  @mailserver_name = 'smtp.gmail.com',
  @port = 587,
  @username = 'your_email@gmail.com',
  @password = 'your_password',
  @use_default_credentials = 0;

  EXEC msdb.dbo.sysmail_add_profile_sp
  @profile_name = 'MyEmailProfile',
  @description = 'Profile for sending email notifications';

  EXEC msdb.dbo.sysmail_add_profileaccount_sp
  @profile_name = 'MyEmailProfile',
  @account_name = 'MyEmailAccount',
  @sequence_number = 1;


--Send a test email
EXEC msdb.dbo.sp_send_dbmail
  @profile_name = 'MyEmailProfile',
  @recipients = 'recipient@example.com',
  @subject = 'Test Email',
  @body = 'This is a test email.';