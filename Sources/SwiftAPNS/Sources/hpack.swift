#if os(Linux)
import Glibc
#else
import Darwin
#endif


public typealias Header = (name: String, value: String)


infix operator **
/// Power of
func ** (radix: Int, power: Int) -> Int {
  return Int(pow(Double(radix), Double(power)))
}
