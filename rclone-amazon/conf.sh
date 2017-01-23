#!/usr/bin/expect
#Author: Xavier

set timeout 1200

set cloud [lindex $argv 0]

spawn rclone config
sleep 1
expect {
"n) New remote" {send "n\n"}
}
expect {
"name>" {send "$cloud\n"}
}
expect {
"Storage>" {send "1\n"}
}
expect {
"client_id>" {send "\n"}
}
expect {
"client_secret>" {send "\n"}
}
expect {
"Use auto config?" {send "y\n"}
}
expect {
"Yes this is OK" {send "y\n"}
}
expect {
" Edit existing remote" {send "q\n"}
}
interact
