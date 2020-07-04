# Defined in /tmp/fish.hSZE9B/connect.fish @ line 2
function connect
	ssh -L 3035:127.0.0.1:3035 -L 3036:127.0.0.1:3036 -L 5000:127.0.0.1:5000 -Y ckrieger@10.10.10.4
end
