read -r -p "mode: 'install' or blank: " m1
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

dir=/persist/passwords/user

if [[ "$m1" == "install" ]]; then
    dir=/mnt/persist/passwords/user
fi
echo "$dir"
mkpasswd -m sha-512 "$p1" | sudo tee $dir
echo
echo "New password written to $dir"
echo "Password will become active next time you run:" 
echo "sudo nixos-rebuild switch"