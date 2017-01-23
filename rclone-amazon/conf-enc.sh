#!/usr/bin/expect
#Author: Xavier

set timeout 1200

set encrypted [lindex $argv 0]

set enc [lindex $argv 1]

set cloud [lindex $argv 2]

spawn rclone config
sleep 1
expect {
"n) New remote" {send "n\n"}
}
expect {
"name>" {send "$encrypted\n"}
}
expect {
"Storage>" {send "5\n"}
}
expect {
"remote>" {send "$cloud:$enc\n"}
}
expect {
"filename_encryption>" {send "2\n"}
}
expect {
"Password or pass phrase for encryption." {send "g\n"}
}
expect {
"Password strength in bits." {send "128\n"}
}
expect {
"Use this password?" {send "y\n"}
}
expect {
"Password or pass phrase for salt. Optional but recommended." {send "g\n"}
}
expect {
"Password strength in bits." {send "128\n"}
}
expect {
"Use this password?" {send "y\n"}
}
expect {
"Yes this is OK" {send "y\n"}
}
expect {
"Current remotes:" {send "q\n"}
}
interact
