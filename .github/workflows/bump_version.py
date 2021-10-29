import re
import sys

with open('map_sync.lua', 'r') as file:
    data = file.readlines()

versionString = len(sys.argv) > 1 and sys.argv[1] or data[3]
version = re.search("\D*(\d+)\.(\d+).*", versionString)
versionLine = version.group(0)
major = version.group(1)
minor = int(version.group(2)) + 1

newVersionLine = re.sub("\"((?:\d+\.?)*)\"", '"{0}.{1}"'.format(major, minor), data[3])
data[3] = newVersionLine


with open('map_sync.lua', 'w') as file:
    file.writelines( data )