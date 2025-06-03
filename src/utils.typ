
/// Returns the duplicate items of an array.
///
/// - arr (array): Array to check.
/// - key (function): Applies this function to the elements in the array to determine the keys to mark as duplicate.
/// ->
#let duplicates(arr, key) = {
  assert(type(arr) == array, message: "Not an array.")
  assert(
    type(key) == function,
    message: "Key is not a function.",
  )

  let dedup_arr = arr.dedup(key: key)
  if dedup_arr.len() == arr.len() {
    return ()
  }

  let dups = ()
  for element in dedup_arr {
    let k = key(element)
    if arr.filter(e => key(e) == k).len() > 1 {
      dups.push(element)
    }
  }

  return dups
}
