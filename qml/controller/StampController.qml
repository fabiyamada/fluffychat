import QtQuick 2.4
import Ubuntu.Components 1.3

Item {

    function getChatTime ( stamp ) {
        var date = new Date ( stamp )
        var now = new Date ()

        var minutes = date.getMinutes () < 10 ? "0" + date.getMinutes () : date.getMinutes ()
        var hours = date.getHours () < 10 ? "0" + date.getHours () : date.getHours ()

        if ( date.getDate()  === now.getDate()  &&
        date.getMonth() === now.getMonth() &&
        date.getFullYear() === now.getFullYear() ) {
            return hours + ":" + minutes
        }

        var mdate = date.getDate () < 10 ? "0" + date.getDate () : date.getDate ()

        var month = date.getMonth() < 9 ? "0" + (date.getMonth()+1) : (date.getMonth()+1)

        var years = date.getFullYear() === now.getFullYear() ? "" : "." + date.getFullYear()

        return mdate + "." + month + years + ", " + hours + ":" + minutes
    }

}
