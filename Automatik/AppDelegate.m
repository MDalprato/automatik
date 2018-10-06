//
//  AppDelegate.m
//  Automatik
//
//  Created by Marco Dalprato on 18/01/15.
//  Copyright (c) 2015 Marco Dalprato. All rights reserved.
//

#import "AppDelegate.h"

#import <IOKit/IOKitLib.h>


@interface AppDelegate ()
@property (weak) IBOutlet NSWindow *window;
@end


// Variabiles declarations ****************

NSString * app_version; // Version of the app (like 1.0)
NSString * matched_time; // time to reach and start the update
NSString * previus_time_saved; // time at the moment of start (or every matching time)
NSString * temp_text_replaced;
NSString * webpage_response = @"Still nothing";

// saved values

NSString * workflow_url_saved;
NSString * workflow_interval_saved;
NSString * update_check_saved;
NSString * notification_wizard_title_saved;
NSString * notification_wizard_body_saved;
NSString * window_wizard_title_saved;
NSString * window_wizard_body_saved;
NSString * advsettings_notification_saved;
NSString * advsettings_windowpopup_saved;
NSString * enabled_advanced_check_saved;
NSString * text_to_search_saved;
NSString * notify_on_ping_check_saved;
NSString * notify_text_search_check_saved;
NSString * ping_status_combo_saved;

NSString * notification_window_x_saved;
NSString * notification_window_y_saved;
NSString * notification_window_w_saved;
NSString * notification_window_h_saved;
NSString * license_counter_saved;

NSString * url_update = @"http://www.marcodalprato.com/wp-content/uploads/automatik/update_version.txt";
NSString * newversion_link = @"http://www.marcodalprato.com/automatik/";
NSString * buy_license = @"https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=X7TG9EF6CF5QA";
NSString * activate_url = @"http://www.marcodalprato.com/wp-content/uploads/automatik/activate.php";

int n = 0;
int license_free_counter = 100; // reach number

// ****************************************

@implementation AppDelegate

@synthesize menu_appinfo;
@synthesize window;
@synthesize workflow_interval;
@synthesize workflow_url;
@synthesize update_check;
@synthesize log_live;
@synthesize verbose_log;
@synthesize notification_wizard_title;
@synthesize notification_wizard_body;
@synthesize window_wizard_body;
@synthesize window_wizard_title;
@synthesize wizard_window;
@synthesize window_wizard_popup_body;
@synthesize advsettings_windowpopup;
@synthesize advsettings_notification;
@synthesize enable_advanced_settings;
@synthesize edit_advanced_settings;
@synthesize text_to_search;
@synthesize notify_on_ping;
@synthesize notify_text_search;
@synthesize ping_status_combo;
@synthesize check_update_button_gui;
@synthesize try_menu_timer;
@synthesize try_menu_loading_page;
@synthesize try_menu_timer_interv;
@synthesize try_menu_notifications;
@synthesize license_window;
@synthesize remaining_license_label;
@synthesize close_window_button_label;
@synthesize product_code;
@synthesize email;
@synthesize activate_license_btn;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	

	NSLog(@"Inizializating Automatik™");
	
	// [self license_check];
	
	[self beta_check];
	
	// prolbem if my website is offline
	 [self check_new_versions_fuction];
	
	[self write_log:@"Initialization of the App"];
	[self load_saved_data];
	
	
	// Get general informations from the app
	app_version =[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	// Set the menu bar information
	menu_appinfo.title = [NSString stringWithFormat:@"Automatik™ %@",app_version];
	
	
	// check if the timer is enabled
	
	if ([update_check_saved isEqualToString:@"1"]) {
		
		[self startTimer:@"controller"];
		
		[self calculate_match_time];
		[self write_log:@"Activation of the timer"];
	}else{
		[self write_log:@"The timer is disabled"];
		[self stopTimer:@"controller"];
		
	}
	
	// load the notification center
	[[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
	


}



-(void)beta_check{
	
	// clear chace
	[[NSURLCache sharedURLCache] removeAllCachedResponses];
	
	
	//first I subscribe the email
	NSString * temp_url = @"http://www.marcodalprato.com/wp-content/uploads/automatik/isbeta.txt";
	
	// NSLog(@"temp_url = %@",temp_url);
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:temp_url]];
	NSError *err;
	NSURLResponse *response;
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
	webpage_response = [[NSString alloc]initWithData:responseData encoding:NSASCIIStringEncoding];
	
	// NSLog(@"%@",webpage_response  );
	
	
	if([webpage_response isEqualTo:@"NO"]){
		
		NSString * private_key_msg = @"Sorry, the beta period of the app is finished. Check marcodalprato.com/automatik for the stable version.";
		
		NSAlert* msgBox = [[NSAlert alloc] init];
		[msgBox setMessageText:private_key_msg];
		[msgBox addButtonWithTitle: @"OK"];
		[msgBox runModal];
		
		[NSApp terminate:self];
		return;
		
	}else{
		
		window.title = @"Automatik™ BETA - This is a beta Version";
		
		[activate_license_btn setHidden:TRUE];
		
	}
	
	NSLog(@"Is beta ? %@", webpage_response);
	

	
	
	}
	 

-(void)license_check{
	

	
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	/* uncoment to reset */
	
	//[defaults setObject:nil forKey:@"license_counter_saved"];
	
	
	
	license_counter_saved			= [[NSUserDefaults standardUserDefaults] objectForKey:@"license_counter_saved"];
	
	
	
	int temp_license_global = [license_counter_saved intValue];
	
	if(temp_license_global == -100){ // license bought
		
		[activate_license_btn setHidden:TRUE];
		
		return;
		
		
	}

	
	if(temp_license_global == 0){
		
		
		[defaults setObject:@"0" forKey:@"license_counter_saved"];
		
		[license_window makeKeyAndOrderFront:self];
		
		[close_window_button_label setEnabled:FALSE];
		
	}else{
		
		[license_window makeKeyAndOrderFront:self];
	
			
			// NSLog(@"Not the first run of the app");
			
			int temp_license = [license_counter_saved intValue];
			
			
			temp_license = temp_license -1;
			
			NSString *temp_license_saved = [NSString stringWithFormat:@"%d",temp_license];
			
			
			[defaults setObject:temp_license_saved forKey:@"license_counter_saved"];
			
			[close_window_button_label setEnabled:TRUE];
			

		
	}
	
	
	if(license_counter_saved == nil){
		
		// NSLog(@"First run of the app");
		
		NSString *temp_license_saved = [NSString stringWithFormat:@"%d",license_free_counter];
		
		license_counter_saved = temp_license_saved ;
		
		[defaults setObject:temp_license_saved forKey:@"license_counter_saved"];
		
		
		[close_window_button_label setEnabled:TRUE];
		
		
	}
	
	remaining_license_label.stringValue = [NSString stringWithFormat:@"Still %@ runs before the expire date.", license_counter_saved];
	

	
	
	
	// NSLog(@"Remaining license = %@",license_counter_saved);
	
}

- (IBAction)startTimer:(id)sender {
	if (!timer) {
		timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
												  target:self
												selector:@selector(timer_action)
												userInfo:nil
												 repeats:YES];		
	}
}

- (IBAction)stopTimer:(id)sender {
	if ([timer isValid]) {
		[timer invalidate];
	}
	timer = nil;
	
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

- (void) awakeFromNib {
	
	// Manage the status bar
	
	_statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
	
	NSImage *menuIcon = [NSImage imageNamed:@"menu_icon.png"];
	NSImage *highlightIcon = [NSImage imageNamed:@"menu_icon.png"]; // Yes, we're using the exact same image asset.
	[highlightIcon setTemplate:YES]; // Allows the correct highlighting of the icon when the menu is clicked.
	
	[[self statusItem] setImage:menuIcon];
	[[self statusItem] setAlternateImage:highlightIcon];
	[[self statusItem] setMenu:[self menu]];
	[[self statusItem] setHighlightMode:YES];
	
}

- (void)write_log:(NSString *)log{
	
	NSDate *currentTime = [NSDate date];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"m-d-yyyy HH:mm:ss"];
	NSString *resultString = [dateFormatter stringFromDate: currentTime];
	
	log_live.stringValue = [NSString stringWithFormat:@"%@ %@ -- %@\n",log_live.stringValue,resultString, log];
	
	
	
}

- (IBAction)menu_showsettings:(id)sender {
	
	// show the settings window
	[window makeKeyAndOrderFront:self];
	[NSApp activateIgnoringOtherApps:YES];
	
}

- (IBAction)menu_quit:(id)sender {
	
	// Terminate the app
	[NSApp terminate:self];
	
}

- (void)update_work{
	
	// clear the log
	log_live.stringValue = @"";
	
	// NSLog(@"Get the response from the URL");
	
	// loading the url
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:workflow_url.stringValue]];
	NSError *err;
	NSURLResponse *response;
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
	webpage_response = [[NSString alloc]initWithData:responseData encoding:NSASCIIStringEncoding];
	
	if(webpage_response) //  response from the url
		{
		// // NSLog(@"webpage_response = ---%@----",webpage_response);
		[self write_log:@"Reaching the URL"];
		
		// if there's a response from the url, check if the advanced mode is enabled, then check if there's the text-to-found in the web page
		
		
		if ([enabled_advanced_check_saved isEqualToString:@"1"])
			
			{ // chek if the notificaion are enabled

			
				// HERE GOES THE LIST OF ALL THE CHECKS NOTIFICATIONS

				
				
		// *******************************************************************************************************************
				
				if ([notify_text_search_check_saved isEqualToString:@"1"])

				{ // check if the search funcition is enabled

				[self write_log:[NSString stringWithFormat:@"String %@ found, match OK", text_to_search_saved]];

					if ([webpage_response rangeOfString:text_to_search_saved].location != NSNotFound) {
						// NSLog(@"string found");
						[self write_log:[NSString stringWithFormat:@"String %@ found, match OK", text_to_search_saved]];

						// calling the advanced settings
						[self advanced_settings_manager];

					} else {

						// NSLog(@"string not found");
						[self write_log:[NSString stringWithFormat:@"String %@ not found, Keep walking ;)", text_to_search_saved]];

					}

				}
				else {[self write_log:@"Notification are disabled"];}
								
				
		// *******************************************************************************************************************
				
				
				if ([notify_on_ping_check_saved isEqualToString:@"1"])
					
					{ // check if the search funcition is enabled
						
						[self write_log:@"Ping is ok"];
						
						
						NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:workflow_url_saved] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
						NSHTTPURLResponse* response = nil;
						NSError* error = nil;
						[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
						
						// NSLog(@"%ld",(long)[response statusCode] );
						
						
						if([ping_status_combo_saved isEqualToString:@"URL is online"]){
							
							// activate if is online
							// response code 200 -> online; 0 -> offline
							
							if ([response statusCode] == 200)
								{
								
								
								[self write_log:@"The URL is online"];
								
								// calling the advanced settings
								[self advanced_settings_manager];
								
								}
							
						}
						
						if([ping_status_combo_saved isEqualToString:@"URL is offline"]){
							
							// activate if is online
							
							// response code 200 -> online; 0 -> offline
							
							if ([response statusCode] == 0)
								{
								
								
								[self write_log:@"The URL is offline"];
								
								// calling the advanced settings
								[self advanced_settings_manager];
								
								}
						}
							
						
						
						
					}
				
				
				else {[self write_log:@"Window are disabled"];}
				
				
				
				
				
				
				
			}

		}
	else
		{
		// NSLog(@"Faield to connect");
		[self write_log:@"Error, can't reach the Url "];
		return;
		
		}

	[self calculate_match_time];
	
	
	
}

-(void) advanced_settings_manager{
	
	// Manage the Notification
	
	if ([advsettings_notification_saved isEqualToString:@"1"]) {
		// NSLog(@"NOTIFICATION");
		[self notification_function];
	}
	
	
	// Manage the Window
	
	if ([advsettings_windowpopup_saved isEqualToString:@"1"]) {
		// NSLog(@"WINDOW");
		[self Window_popup_function];
	}
	
}

- (IBAction)save_button:(id)sender {
	
	[self save_function];
}

- (IBAction)clear_log_button:(id)sender {
	
	// clear the log
	log_live.stringValue = @"";
}

- (void)timer_action { // check the current time to the set matched time
	
	NSDate *currentTime = [NSDate date];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"HH:mm:ss"];
	NSString * time_now = [dateFormatter stringFromDate: currentTime];
	
	n= n +1;
	
		if([time_now isEqualToString:matched_time]){
			
			
			if([update_check.stringValue isEqualToString:@"1"]){
				// NSLog(@"ARRIVATO !!");
				[self update_work]; // event only if timer enabled
				
			}
			
			
		}

	
	if ([verbose_log.stringValue isEqualToString:@"1"]) {
		
		[self write_log:[NSString stringWithFormat:@"Timer Event (next check at %@)",matched_time]];
		
	}
	// NSLog(@" --- Timer event");
		
	
}

- (void)calculate_match_time{
	
	// get the current time and save it, also add the timing in seconds to the current time saved
	
	NSDate *currentTime = [NSDate date];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"HH:mm:ss"];
	previus_time_saved = [dateFormatter stringFromDate: currentTime];
	
	NSDate *summed_time = [currentTime dateByAddingTimeInterval:[workflow_interval_saved intValue]];
	
	matched_time = [dateFormatter stringFromDate: summed_time];
	
	// NSLog(@"%@ // %@",previus_time_saved,matched_time);
	
	[self write_log:[NSString stringWithFormat:@"Time to reach: %@",matched_time]];
	

}

- (void)save_function{
	
 // allow only alphanumeric chars

	if([workflow_interval.stringValue isEqual:@""]){
		
		
		NSString * private_key_msg = @"Sorry, the interval must be a valid number";
		
		NSAlert* msgBox = [[NSAlert alloc] init];
		[msgBox setMessageText:private_key_msg];
		[msgBox addButtonWithTitle: @"OK"];
		[msgBox runModal];
		
		[self load_saved_data];
		return;

		
	}
	
	if([workflow_interval.stringValue isEqual:@"0"]){
		
		
		NSString * private_key_msg = @"Sorry, the interval must be a valid number";
		
		NSAlert* msgBox = [[NSAlert alloc] init];
		[msgBox setMessageText:private_key_msg];
		[msgBox addButtonWithTitle: @"OK"];
		[msgBox runModal];
		
		[self load_saved_data];
		return;
		
		
	}
	
	
	/*
	
	if(![self validateUrl:workflow_url.stringValue]){

				NSString * private_key_msg = @"Sorry, check the url, isn't correct";
				
				NSAlert* msgBox = [[NSAlert alloc] init];
				[msgBox setMessageText:private_key_msg];
				[msgBox addButtonWithTitle: @"OK"];
				[msgBox runModal];
				
				[self load_saved_data];
				return;
	}
	*/
	
	
	
	NSString* newStr = [workflow_interval.stringValue stringByTrimmingCharactersInSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]];
	if([workflow_interval.stringValue isEqualToString: newStr]) {

		
		// save all the data
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		
		[defaults setObject:workflow_url.stringValue forKey:@"workflow_url_saved"];
		[defaults setObject:workflow_interval.stringValue forKey:@"workflow_interval_saved"];
		[defaults setObject:update_check.stringValue forKey:@"update_check_saved"];
		[defaults setObject:enable_advanced_settings.stringValue forKey:@"enabled_advanced_check_saved"];
		[defaults setObject:text_to_search.stringValue forKey:@"text_to_search_saved"];
		
		// save Notification wizard
		
		[defaults setObject:notification_wizard_title.stringValue forKey:@"notification_wizard_title_saved"];
		[defaults setObject:notification_wizard_body.stringValue forKey:@"notification_wizard_body_saved"];
		
		// save window wizard
		
		[defaults setObject:window_wizard_title.stringValue forKey:@"window_wizard_title_saved"];
		[defaults setObject:window_wizard_body.stringValue forKey:@"window_wizard_body_saved"];
		
		// notification window tabs
		
		[defaults setObject:advsettings_notification.stringValue forKey:@"advsettings_notification_saved"];
		[defaults setObject:advsettings_windowpopup.stringValue forKey:@"advsettings_windowpopup_saved"];
		
		// advanced checked
		
		[defaults setObject:notify_on_ping.stringValue forKey:@"notify_on_ping_check_saved"]; // check ping
		[defaults setObject:notify_text_search.stringValue forKey:@"notify_text_search_check_saved"]; // check ping
		[defaults setObject:ping_status_combo.stringValue forKey:@"ping_status_combo_saved"]; // check ping
		
		
		
	
		
		// window size
		
		[defaults setObject:[NSString stringWithFormat:@"%f",wizard_window.frame.origin.x] forKey:@"notification_window_x_saved"]; // check ping
		[defaults setObject:[NSString stringWithFormat:@"%f",wizard_window.frame.origin.y] forKey:@"notification_window_y_saved"]; // check ping
		[defaults setObject:[NSString stringWithFormat:@"%f",wizard_window.frame.size.width] forKey:@"notification_window_w_saved"]; // check ping
		[defaults setObject:[NSString stringWithFormat:@"%f",wizard_window.frame.size.height] forKey:@"notification_window_h_saved"]; // check ping
		
		

		
		
		

		
		[defaults synchronize];
		
		[self load_saved_data];
		
		[self write_log:@"Saving the configuration -- "];
		
		[self write_log:[NSString stringWithFormat:@"Workflow url saved: %@",workflow_url_saved]];
		[self write_log:[NSString stringWithFormat:@"Workflow Interval saved: %@",workflow_interval_saved]];
		[self write_log:[NSString stringWithFormat:@"Update check saved: %@",workflow_interval_saved]];
	
		[self write_log:[NSString stringWithFormat:@"Notification Title: %@",notification_wizard_title_saved]];
		[self write_log:[NSString stringWithFormat:@"Notification Body: %@",notification_wizard_body_saved]];
		
		[self write_log:[NSString stringWithFormat:@"Window Title: %@",window_wizard_title_saved]];
		[self write_log:[NSString stringWithFormat:@"Window Body: %@",window_wizard_body_saved]];
		
		if ([update_check_saved isEqualToString:@"1"]) {
			
			[self startTimer:@"controller"];
			
			[self calculate_match_time];
			[self write_log:@"Activation of the timer"];
		}else{
			[self write_log:@"The timer is disabled"];
			[self stopTimer:@"controller"];
			
		}
		
		
		
		
		
	}
	else{
		
		NSString * private_key_msg = @"Sorry, I can reach only numbers, not words ;) ";
		
		NSAlert* msgBox = [[NSAlert alloc] init];
		[msgBox setMessageText:private_key_msg];
		[msgBox addButtonWithTitle: @"OK"];
		[msgBox runModal];
		
		[self load_saved_data];
		return;
		
	}
		

}

- (void)load_saved_data{
	
	workflow_url_saved				= [[NSUserDefaults standardUserDefaults] objectForKey:@"workflow_url_saved"];
	workflow_interval_saved			= [[NSUserDefaults standardUserDefaults] objectForKey:@"workflow_interval_saved"];
	update_check_saved				= [[NSUserDefaults standardUserDefaults] objectForKey:@"update_check_saved"];
	enabled_advanced_check_saved	= [[NSUserDefaults standardUserDefaults] objectForKey:@"enabled_advanced_check_saved"];
	text_to_search_saved			= [[NSUserDefaults standardUserDefaults] objectForKey:@"text_to_search_saved"];

	
	// Notification wizard
	
	notification_wizard_body_saved    = [[NSUserDefaults standardUserDefaults] objectForKey:@"notification_wizard_body_saved"];
	notification_wizard_title_saved   = [[NSUserDefaults standardUserDefaults] objectForKey:@"notification_wizard_title_saved"];
	
	// Window wizard
	
	window_wizard_title_saved		= [[NSUserDefaults standardUserDefaults] objectForKey:@"window_wizard_title_saved"];
	window_wizard_body_saved		= [[NSUserDefaults standardUserDefaults] objectForKey:@"window_wizard_body_saved"];

	
	// // notification window tabs
	
	advsettings_notification_saved	= [[NSUserDefaults standardUserDefaults] objectForKey:@"advsettings_notification_saved"];
	advsettings_windowpopup_saved	= [[NSUserDefaults standardUserDefaults] objectForKey:@"advsettings_windowpopup_saved"];

	
	
	// advanced checked
	
	notify_on_ping_check_saved	= [[NSUserDefaults standardUserDefaults] objectForKey:@"notify_on_ping_check_saved"];
	notify_text_search_check_saved	= [[NSUserDefaults standardUserDefaults] objectForKey:@"notify_text_search_check_saved"];
	ping_status_combo_saved	= [[NSUserDefaults standardUserDefaults] objectForKey:@"ping_status_combo_saved"];
	
	
	notification_window_x_saved	= [[NSUserDefaults standardUserDefaults] objectForKey:@"notification_window_x_saved"];
	notification_window_y_saved	= [[NSUserDefaults standardUserDefaults] objectForKey:@"notification_window_y_saved"];
	notification_window_w_saved	= [[NSUserDefaults standardUserDefaults] objectForKey:@"notification_window_w_saved"];
	notification_window_h_saved	= [[NSUserDefaults standardUserDefaults] objectForKey:@"notification_window_h_saved"];
	
	


	
	if ([enabled_advanced_check_saved isEqualToString:@"0"]) {
		
		[enable_advanced_settings setState:0];
		[edit_advanced_settings setEnabled:FALSE];
		[try_menu_notifications setState:0];
	
	} else {
		
		[enable_advanced_settings setState:1];
		[edit_advanced_settings setEnabled:TRUE];
		[try_menu_notifications setState:1];
	
	}
	
	if ([update_check_saved isEqualToString:@"0"]) {
		[update_check setState:0];
		[try_menu_timer setState:0];
	

	} else {
		
		[update_check setState:1];
		[try_menu_timer setState:1];
	
	}
	
	// notification widnow checks
	
	if ([advsettings_notification_saved isEqualToString:@"0"]) {[advsettings_notification setState:0];} else {[advsettings_notification setState:1];}
	if ([advsettings_windowpopup_saved isEqualToString:@"0"]) {[advsettings_windowpopup setState:0];} else {[advsettings_windowpopup setState:1];}
	
	// notificaiton checks
	
	if ([notify_on_ping_check_saved isEqualToString:@"0"]) {[notify_on_ping setState:0];} else {[notify_on_ping setState:1];}
	if ([notify_text_search_check_saved isEqualToString:@"0"]) {[notify_text_search setState:0];} else {[notify_text_search setState:1];}
	
	
	[ping_status_combo setStringValue:ping_status_combo_saved];
	
	text_to_search.stringValue = text_to_search_saved;
	workflow_url.stringValue = workflow_url_saved;
	workflow_interval.stringValue = workflow_interval_saved;
	
	// notification wizard populate
	
	notification_wizard_body.stringValue = notification_wizard_body_saved;
	notification_wizard_title.stringValue = notification_wizard_title_saved;

	
	// wizard window populate (wizard & popup window)
	
	window_wizard_body.stringValue = window_wizard_body_saved;
	window_wizard_title.stringValue = window_wizard_title_saved;
	
	window_wizard_popup_body.stringValue = window_wizard_body_saved;
	wizard_window.title = window_wizard_title_saved;
	
	NSRange stringRange = {6,10};
		NSString *shortString = [workflow_url_saved substringWithRange:stringRange];
	
	try_menu_loading_page.title = [NSString stringWithFormat:@"URL: %@ ...", shortString];
	try_menu_timer_interv.title = [NSString stringWithFormat:@"Interval is set to %@ seconds", workflow_interval_saved];

	
	
}

- (void)notification_function{
	
	[self save_function];
	[self load_saved_data];
	
	[self Replacing_function:notification_wizard_body_saved];

	NSUserNotification *notification = [[NSUserNotification alloc] init];
	notification.title = notification_wizard_title_saved;
	notification.informativeText = temp_text_replaced;
	notification.soundName = NSUserNotificationDefaultSoundName;
	
	[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];

}

- (void)Window_popup_function{
	
	[self save_function];
	[self load_saved_data];
	
	notification_window_x_saved	= [[NSUserDefaults standardUserDefaults] objectForKey:@"notification_window_x_saved"];
	notification_window_y_saved	= [[NSUserDefaults standardUserDefaults] objectForKey:@"notification_window_y_saved"];
	notification_window_w_saved	= [[NSUserDefaults standardUserDefaults] objectForKey:@"notification_window_w_saved"];
	notification_window_h_saved	= [[NSUserDefaults standardUserDefaults] objectForKey:@"notification_window_h_saved"];
	
	
	
	[self Replacing_function:window_wizard_body_saved];
	
	// show window
	[wizard_window makeKeyAndOrderFront:self];
	
	window_wizard_popup_body.stringValue =temp_text_replaced;
	
	
	
	// [wizard_window setFrame:NSMakeRect(notification_window_x_saved.floatValue, notification_window_y_saved.floatValue, notification_window_w_saved.floatValue, notification_window_y_saved.floatValue) display:YES animate:YES];
	
	[wizard_window setFrame:NSMakeRect(notification_window_x_saved.floatValue, notification_window_y_saved.floatValue, notification_window_w_saved.floatValue , notification_window_h_saved.floatValue) display:YES animate:YES];
	
}

- (IBAction)save_notification_wizard:(id)sender {
	
	// call save function
	[self save_function];
}

- (IBAction)try_notification_wizard:(id)sender {
	
	[self notification_function];

}

- (IBAction)save_window_wizard:(id)sender {
	

	// NSLog(@"size: %f, %f", wizard_window.frame.origin.x,wizard_window.frame.origin.y );
	
	// NSLog(@"size: %f x %f", wizard_window.frame.size.width, wizard_window.frame.size.height);
	
	
	
	// call save function
	[self save_function];
}

- (IBAction)try_window_wizard:(id)sender {
	
	[self Window_popup_function];
	
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
	return YES;
}

- (IBAction)advsettings_notification_btn:(id)sender {
	
	// call save function
	[self save_function];
}

- (IBAction)advsettings_windowpopup_btn:(id)sender {
	
	// call save function
	[self save_function];
}

- (IBAction)enable_advanced_settings_btn:(id)sender {

	
	if ([enable_advanced_settings.stringValue isEqualToString:@"0"]) {
		
		[edit_advanced_settings setEnabled:FALSE];
		
	} else {
		
		[edit_advanced_settings setEnabled:TRUE];
		
	}
	
}

- (void)Replacing_function:(NSString *)text_should_replace{
	
	// Code that I need for the replacing function
	
	NSDate *currentTime = [NSDate date];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
	NSDateFormatter *dateFormatter3 = [[NSDateFormatter alloc] init];
	
	[dateFormatter setDateFormat:@"m-d-yyyy"];
	[dateFormatter2 setDateFormat:@"HH:mm:ss"];
	[dateFormatter3 setDateFormat:@"HH:mm"];
	
	temp_text_replaced=[text_should_replace stringByReplacingOccurrencesOfString:@"[@date]" withString:[dateFormatter stringFromDate: currentTime]];
	temp_text_replaced=[temp_text_replaced stringByReplacingOccurrencesOfString:@"[@time_seconds]" withString:[dateFormatter2 stringFromDate: currentTime]];
	temp_text_replaced=[temp_text_replaced stringByReplacingOccurrencesOfString:@"[@time]" withString:[dateFormatter3 stringFromDate: currentTime]];
	
	// replacing with the response
	
	temp_text_replaced=[temp_text_replaced stringByReplacingOccurrencesOfString:@"[@web_response]" withString:webpage_response];

	// // NSLog(@"temp_text_replaced = %@",temp_text_replaced);

	
}

- (IBAction)notify_text_search_btn:(id)sender {

}

- (IBAction)notify_on_ping_btn:(id)sender {

}

- (BOOL) validateUrl: (NSString *) candidate {
	
	
	NSString *urlRegEx =
	@"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
	NSPredicate *urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
	return [urlTest evaluateWithObject:candidate];
	
	
}

-(void)check_new_versions_fuction{
	
	// // NSLog(@"Check for new versions");
	/*
	 
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url_update]];
	NSError *err;
	NSURLResponse *response;
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
	webpage_response = [[NSString alloc]initWithData:responseData encoding:NSASCIIStringEncoding];
	
	app_version =[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
		
	float current_app_version = [app_version floatValue];
	float last_app_version = [webpage_response floatValue];
	// NSLog(@"webpage_response = %@", webpage_response);
	
	
	// NSLog(@"local version = %f", current_app_version);
	// NSLog(@"Remote version = %f", last_app_version);
	
	
	if(last_app_version > current_app_version){

		
		
		check_update_button_gui.title = @"New Version Available";
		check_update_button_gui.enabled = true;
		
		
	}else{
		
		check_update_button_gui.title = @"No new version available";
		check_update_button_gui.enabled = false;
		
	}
	 
	 */
	
	check_update_button_gui.title = @"No new version available";
	check_update_button_gui.enabled = false;
	
	
} // function for check new versions

- (IBAction)check_updates_button:(id)sender {
	

	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:newversion_link]];

}

- (IBAction)try_menu_timer_btn:(id)sender {

	
	
	if ([update_check.stringValue isEqualToString:@"1"]){// if timer is active
		
		
		[update_check setState:0];
		
		
	}else{
		
		[update_check setState:1];
		
		
	}
	
	[self save_function];
	[self load_saved_data];
	
	
	
}

- (IBAction)try_menu_notifications_btn:(id)sender {
	
	if ([enable_advanced_settings.stringValue isEqualToString:@"1"]){// if timer is active
		
		
		[enable_advanced_settings setState:0];
		
		
	}else{
		
		[enable_advanced_settings setState:1];
		
		
	}
	
	[self save_function];
	[self load_saved_data];
	
	
	
}

- (IBAction)activate_button:(id)sender {
	
	
	//first I subscribe the email
	NSString * temp_url = [NSString stringWithFormat:@"%@?email=%@&serial=%@&registration_code=%@",activate_url,email.stringValue,[self serialNumber], product_code.stringValue];
	
	// NSLog(@"temp_url = %@",temp_url);
	
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:temp_url]];
	NSError *err;
	NSURLResponse *response;
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
	webpage_response = [[NSString alloc]initWithData:responseData encoding:NSASCIIStringEncoding];
	
	// NSLog(@"%@",webpage_response  );
	
	
	if ([webpage_response rangeOfString:@"License VALID"].location != NSNotFound) {
			
			
		
		// NSLog(@"License Activated");
		
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		[defaults setObject:@"-100" forKey:@"license_counter_saved"];
		
		[license_window close];
		
	}else{
	
		NSString * private_key_msg = @"Sorry, the license is not valid";
		
		NSAlert* msgBox = [[NSAlert alloc] init];
		[msgBox setMessageText:private_key_msg];
		[msgBox addButtonWithTitle: @"OK"];
		[msgBox runModal];
		
		[NSApp terminate:self];
		return;
		
	}
	
	// "0 results";
	
}

- (IBAction)close_license_window_button:(id)sender {
	
	[license_window close];
}

- (NSString *)serialNumber
{
	
	// // NSLog(@"serial = %@",[self serialNumber]);
	
	io_service_t    platformExpert = IOServiceGetMatchingService(kIOMasterPortDefault,
																 
																 IOServiceMatching("IOPlatformExpertDevice"));
	CFStringRef serialNumberAsCFString = NULL;
	
	if (platformExpert) {
		serialNumberAsCFString = IORegistryEntryCreateCFProperty(platformExpert,
																 CFSTR(kIOPlatformSerialNumberKey),
																 kCFAllocatorDefault, 0);
		IOObjectRelease(platformExpert);
	}
	
	NSString *serialNumberAsNSString = nil;
	if (serialNumberAsCFString) {
		serialNumberAsNSString = [NSString stringWithString:(__bridge NSString *)serialNumberAsCFString];
		CFRelease(serialNumberAsCFString);
	}
	
	return serialNumberAsNSString;
}

- (IBAction)buy_license:(id)sender {
	
	
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:buy_license]];
	
	
}
- (IBAction)activate_license_button:(id)sender {
	
	[license_window makeKeyAndOrderFront:self];
}
@end
