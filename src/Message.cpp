#include "Message.h"
#include <iostream>
#include <iomanip>
#include <initializer_list>

#include <utility> 

Message::Message(std::initializer_list<uint8_t> b) 
    : std::vector<uint8_t>(b)
{}
Message::Message(uint8_t *msg, size_t size) 
    : std::vector<uint8_t>(size,0) 
    {
        for (size_t i=0; i < size; ++i) {
            push_back(msg[i]);
        }
    }
Message::Message(std::vector<uint8_t> v) 
    : std::vector<uint8_t>(v)
    {
    }

bool Message::isRaw() const { return size() && front() == 0; }


std::ostream& operator<<(std::ostream &out, const Message &msg) {
    for (auto byte : msg) {
        out << std::setw(2) << std::hex << std::setfill('0') 
            << static_cast<unsigned>(byte);
    }
    return out;
}

#if 0
int main() {
    Message m{0x06, 0x21, 1};
    std::cout << m << "\n";
    std::cout << (m.isRaw() ? "plain" : "not plain") << "\n";
}
#endif