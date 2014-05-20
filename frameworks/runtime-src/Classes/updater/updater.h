#ifndef __UPDATER_H__
#define __UPDATER_H__

#include <string>
#include <map>

namespace updater {
    typedef std::map<std::string, int> assetsDataMap;
    typedef struct { assetsDataMap files, directories; } assetsData;
#define ASSETS_DATA_MAP_ITERATE(map) \
    for (assetsDataMap::iterator i = (map).begin(); i != (map).end(); i++)

    void readAssetsData(const char *dataFile, assetsData &out);
    void removeDirectory(std::string filename);
    void createDirectory(std::string filename);
    void removeFile(std::string filename);
    void downloadFile(std::string onlineFile, std::string localFile);
    void checkUpdate(std::string rootdir);
}

#endif
