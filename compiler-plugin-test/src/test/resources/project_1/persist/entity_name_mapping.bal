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

@sql:Mapping {name: ""}
public type Appointment record {|
    readonly int id;
    string reason;
    time:Civil appointmentTime;
    AppointmentStatus status;
    int _patientId;
    int doctorId;
|};

@sql:Mapping {name: "Patient"}
public type Patient record {|
    readonly int id;
    string name;
    int age;
    string address;
    string phoneNumber;
    PatientGender gender;
|};

@sql:Mapping {name: "staff"}
public type Doctor record {|
    readonly int id;
    string name;
    string specialty;
    string phoneNumber;
|};

@sql:Mapping {name: "staff"}
public type Nurse record {|
    readonly int id;
    string name;
    string phoneNumber;
|};

@sql:Mapping {name: "receptioninst"}
public type Receptionist record {|
    readonly int id;
    string name;
    string phoneNumber;
|};
