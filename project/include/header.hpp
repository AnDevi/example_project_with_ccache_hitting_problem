#pragma once

namespace myproject {

    class Project {
    public:
        Project(int major, int minor) {
            _version.major = major;
            _version.minor = minor;        
        }
        void print() const { cout << "Project print: " << _version.major << "." << _version.minor << endl; }
    private:
        ProjectVersion _version;
    };
}