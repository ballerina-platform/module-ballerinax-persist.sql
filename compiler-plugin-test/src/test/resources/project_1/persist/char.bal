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
    @sql:Char {length: 100}
    @sql:VarChar {length: 20}
    string reason;
    time:Civil appointmentTime;
    AppointmentStatus status;
    int _patientId;
    int doctorId;
|};

public type Patient record {|
    readonly int id;
    @sql:Char {length: 0}
    string name;
    @sql:Char {length: 10}
    int age;
    string address;
    string phoneNumber;
    PatientGender gender;
|};

