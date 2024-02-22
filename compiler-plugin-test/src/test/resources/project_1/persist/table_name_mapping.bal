import ballerina/persist as _;
import ballerina/time;
import ballerinax/persist.sql;

public enum AppointmentStatus {
    SCHEDULED = "SCHEDULED",
    STARTED = "STARTED",
    ENDED = "ENDED"
}

public enum PatientGender {
    MALE = "MALE",
    FEMALE = "FEMALE"
}

public type Appointment record {|
    readonly int id;
    @sql:Mapping {name: "REASON"}
    string reason;
    time:Civil appointmentTime;
    @sql:Mapping {name: ""}
    AppointmentStatus status;
|};

public type Patient record {|
    readonly int id;
    string name;
    int age;
    @sql:Mapping {name: "Address"}
    string address;
    @sql:Mapping {name: "phoneNumber1"}
    string phoneNumber;
    @sql:Mapping {name: "phoneNumber1"}
    string phoneNumber2;
    PatientGender gender;
|};

public type Doctor record {|
    readonly int id;
    string name;
    string specialty;
    @sql:Mapping {name: "Address"}
    string address;
    @sql:Mapping {name: "phoneNumber"}
    string phoneNumber;
|};


