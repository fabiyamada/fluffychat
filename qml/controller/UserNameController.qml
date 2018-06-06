import QtQuick 2.4
import Ubuntu.Components 1.3

/*============================= USERNAME CONTROLLER ============================
The username controller is just a little helper to get the user display name
from a userid address, such like: "#alice@matrix.org"
*/

Item {
    function getById ( matrixid, roomid, callback ) {
        storage.transaction ( "SELECT displayname FROM Roommembers WHERE state_key='" + matrixid + "'", function(rs) {
            if ( rs.rows.length > 0 ) callback ( rs.rows[0].displayname )
            else {
                var username = transformFromId( matrixid )
                callback ( username )
            }
        })
    }

    function transformFromId ( matrixid ) {
        return capitalizeFirstLetter ( (matrixid.substr(1)).split(":")[0] )
    }

    function capitalizeFirstLetter(string) {
        return string.charAt(0).toUpperCase() + string.slice(1);
    }
}
