#Playbook by Heathers S 5/2021
#IPA Client Enrollment
#Root is needed to run the ipa-client-install command
#FQDN needs to be set before running this! ipa-client-install WILL fail without an FQDN (gracefully and informatively)
#Add lines for this if needed, I did not as the orginal project this was for this was unessicarily complicated for a one time task
---
- name: Install IPA client
  hosts: XXXX
  become: yes
  become_user: root

#CHeck DNS and hostnames here if there's any question they may not be set appropriately

  - name: Install IPA client installer
    apt:
      name: freeipa-client
      state: present 
#Will fail gracefully if the client is enrolled/command is idempotent
#Expected error is  "IPA client is already configured on this system."
#mkhomedir is important otherwise new users won't get home directiries added, no-ntp tells freeIPA not to take over NTP duties (you generally don't want this)
  - name: Enroll Client
    command: "ipa-client-install --mkhomedir --no-ntp -U -w {{ freeipa_pass }} -p {{ freeipa_user }}"
