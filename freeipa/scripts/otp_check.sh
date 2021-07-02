#!/bin/bash

#IPA Script: Check for users without set token
#Users will be able to set their own tokens. This script is to check for anyone who does not as OTP authentication will not work until a token is set and will default back to password only.

#Might be able to be run not on IPA host but most easily run there. Be sure to run 'kinit admin' before running this or the ipa command will not work!

#Use LDAP search to get user's password change date and filter down to lines in the form of 'username datestring'
ldapsearch  "(ipaUserAuthType=otp)" krbLastPwdChange 2> /dev/null |grep -v ^# | grep ^[dk] | awk '{print $2}' | awk -F "," '{print $1}' | sed s/uid=// | sed s/Z// | sed -e '/./N;y/\n/ /' > passchng

#This should be set to a date after the accounts were created in Ansible but before users would have started changing logins.
CHECKDATE=20210325195800

#Grabs all users who have set a password
awk '{ if ($2 > '$CHECKDATE') print $1 }' passchng >> passfilt

#Grabs all users who have set up a token
ipa otptoken-find | awk '{ if ($0 ~ "Owner") print $2}' > otp

#Comm requires sorted lists
sort otp > otpsort
sort passfilt > passfiltsort

#Use comm to find users who have not set a token!
echo "Users in this list have set a password but not a token!!" > output
comm -13 otp passfilt >> output

#remove trash files
rm -f otp* pass*

