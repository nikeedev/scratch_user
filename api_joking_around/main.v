module main

import net.http
import term
import time
import json
import os
import zztkm.vdotenv

/// For Authentication
struct User {
mut:
	username string
	password string
}

///

struct SessionInfo {
	user struct {
		id            int
		banned        bool
		username      string
		token         string
		thumbnail_url string [json: 'thumbnailUrl']
		date_joined   string [json: 'dateJoined']
		email         string
	}

	permissions struct {
		admin             bool
		scratcher         bool
		new_scratcher     bool
		invited_scratcher bool
		social            bool
		educator          bool
		educator_invitee  bool
		student           bool
	}

	flags struct {
		must_reset_password                bool
		must_complete_registration         bool
		has_outstanding_email_confirmation bool
		show_welcome                       bool
		confirm_email_banner               bool
		unsupported_browser_banner         bool
		project_comments_enabled           bool
		gallery_comments_enabled           bool
		userprofile_comments_enabled       bool
		everything_is_totally_normal       bool
	}
}

///

fn main() {
	getusername := os.input("Write your username: ")
	getpassword := os.input_password("Write your user's password: ")!

	user := User{
		username: getusername
		password: getpassword
	}

	// user := User{username: os.getenv("USERNAMEenv"), password: os.getenv("PASSWORDenv")}

	mut login_conf := http.FetchConfig{
		url: 'https://scratch.mit.edu/login/'
		data: json.encode(user)
		method: .post
	}

	login_conf.cookies['scratchcsrftoken'] = 'a'

	login_conf.header.add_custom('X-Requested-With', 'XMLHttpRequest')!
	login_conf.header.add_custom('X-CSRFToken', 'a')!
	login_conf.header.add_custom('Referer', 'https://scratch.mit.edu')!
	login_conf.header.add_custom('Cookie', 'scratchcsrftoken=a;')!
	login_conf.header.add_custom('User-Agent', 'scratch_user 1.0')!
	login_conf.header.add_custom('Content-Type', 'application/json')!

	mut sessionid_response := http.fetch(login_conf)!
	// println(sessionid_response)
	os.write_file('login_response.json', sessionid_response.body)!
	my_cookie := sessionid_response.cookies()[0].value
	println(my_cookie)

	mut message_conf := http.FetchConfig{
		url: 'https://api.scratch.mit.edu/users/nikeedev/projects/819058933'
		method: .get
	}

	message_conf.header.add_custom('X-Requested-With', 'XMLHttpRequest')!
	message_conf.header.add_custom('cookie', 'scratchsessionsid=${my_cookie};')!
	message_conf.header.add_custom('Referer', 'https://scratch.mit.edu/')!
	message_conf.header.add_custom('Content-Type', 'application/json')!

	mut message_response := http.fetch(message_conf)!
	// println(message_response.body)
	os.write_file('msg_response.json', message_response.body)!
	println(message_response.body)
	println(message_response)

	println('\n')
}
