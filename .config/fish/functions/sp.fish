# Defined in /tmp/fish.QIZGEU/sp.fish @ line 1
function sp
	ssh (fwd 172.29.24.183 3000 3035 3036 5000) -t 'cd ~/src/status-page-web && exec $SHELL --login'
end
