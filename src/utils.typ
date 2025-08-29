// Map function similar to `arr.map(func)' but with an additional paramater to
// `func': the index:
//
// - arr (array): Input list.
// - func (function): `((any, int) -> any)`
// -> any
#let mapi(arr, func) = {
  let result = ()
  for index in range(arr.len()) {
    result.push(func(arr.at(index), index))
  }
  return result
}

// Concatenates the string `with' to the begining of `str' until it is `count'
// characters long.
//
// - str (string): The base string
// - count (int): The minimum length of target string
// - with (string): The string to use to pad
// -> str
#let left-pad(str, count, with) = {
  while str.len() < count { str = with + str }
  return str
}
