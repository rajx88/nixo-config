# read password twice
read -r -s -p "Enter New User Password: " p1
echo 
read -r -s -p "Password (again): " p2
echo

if [[ "$p1" != "$p2" ]]; then
  echo "Passwords do not match! Exiting ..."
  exit
elif
  [[ "$p1" == "" ]]; then
  echo "Empty password. Exiting ..."
  exit
fi

mkpasswd -m sha-512 "$p1" | sudo tee /persist/passwords/user
echo
echo "New password written to /persist/passwords/user"
echo "Password will become active next time you run:" 
echo "sudo nixos-rebuild switch"