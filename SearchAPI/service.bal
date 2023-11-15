import ballerina/http;
import ballerina/log;
import ballerinax/salesforce;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    resource function get search(string email) returns Contact[]|error? {

        log:printInfo("search for", email = email);
        salesforce:Client salesforceEp = check new (config = {
            baseUrl: baseUrl,
            auth: {
                refreshUrl: refreshUrl,
                refreshToken: refreshToken,
                clientId: clientId,
                clientSecret: clientSecret
            }
        });

        stream<SFContact, error?> queryResponse = check salesforceEp->query(soql = string `SELECT Id,FirstName,LastName,Email,Phone FROM Contact WHERE (Email = '${email}')`);
    
        Contact[] contacts = [];

        check queryResponse.forEach(function (SFContact sfContact) {
            contacts.push(transform(sfContact));
        });
        
        return contacts;
    }
}

configurable string baseUrl = ?;
configurable string refreshUrl = ?;
configurable string refreshToken = ?;
configurable string clientId = ?;
configurable string clientSecret = ?;


type SFContact record {
    record {
        string 'type;
        string url;
    } attributes;
    string Id;
    string FirstName;
    string LastName;
    string Email;
    string Phone;
};

type Contact record {
    string fullName;
    string phoneNumber;
    string email;
    string id;
};

function transform(SFContact sfContact) returns Contact => {
    id: sfContact.Id,
    fullName: sfContact.FirstName + sfContact.LastName,
    email: sfContact.Email,
    phoneNumber: sfContact.Phone
};
