{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [ openvpn ];

  services.openvpn.servers.con01 = {
    config = "config /etc/openvpn/con01.ovpn";
    autoStart = false;
  };

  environment.persistence."/persist".directories = [ "/etc/openvpn" ];

  programs.zsh.shellAliases = {
    ovpn-start = "sudo systemctl start openvpn-con01";
    ovpn-stop  = "sudo systemctl stop openvpn-con01";
    ovpn-logs  = "journalctl -u openvpn-con01 -f";
  };
}
