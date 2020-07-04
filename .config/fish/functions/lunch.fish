# Defined in /tmp/fish.F3hWjj/lunch.fish @ line 1
function lunch
	curl -s https://word-to-your-menu.us-west-2.prod.atl-paas.net/menu/sf/today | hxselect -c h3 | hxremove span
end
