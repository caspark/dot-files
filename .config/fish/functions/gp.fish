# Defined in /tmp/fish.uqThuP/gp.fish @ line 1
function gp
	git push origin -u (git rev-parse --abbrev-ref HEAD)
end
