import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.DownloadManager 1.2

/* =============================== MEDIA CONTROLLER ===============================

Little helper controller for downloading thumbnails and all content via mxc uris.
*/

Item {

    property var callback: console.log("Download finished")


    function getThumbnailFromMxc ( mxc, width, height ) {
        if ( mxc === undefined ) return ""

        var mxcID = mxc.replace("mxc://","")

        return "https://" + settings.server + "/_matrix/media/r0/thumbnail/" + mxcID + "/?width=" + width + "&height=" + height + "&method=crop"
    }


    function getLocalThumbnailFromMxc ( mxc ) {
        if ( mxc === undefined ) return ""

        var mxcID = mxc.replace("mxc://","").split("/")[1]
        return "../../Downloads/%1".arg(mxcID)
    }


    function downloadThumbnailFromMxc ( mxc, width, height, cb ) {
        callback = cb
        downloader.download ( getThumbnailFromMxc ( mxc, width, height ) )
    }


    function getImageLinkFromMxc ( mxc ) {
        if ( mxc === undefined ) return ""
        var mxcID = mxc.replace("mxc://","")
        return "https://" + server + "/_matrix/media/r0/download/" + mxcID + "/download.jpg"
    }


    SingleDownload {
        id: downloader
        onProgressChanged: console.log("Progress:", progress)
        onFinished: callback ( path )
    }

}
