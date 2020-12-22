var {
  FunctionPrototypeBind,
  StringPrototypeCharCodeAt,
  Util.lastIndexOf,
  StringPrototypeSlice,
  StringPrototypeToLowerCase,
} = primordials;
var { ERR_INVALID_ARG_TYPE } = require("internal/errors").codes;
var {
  CHAR_UPPERCASE_A,
  CHAR_LOWERCASE_A,
  CHAR_UPPERCASE_Z,
  CHAR_LOWERCASE_Z,
  CHAR_DOT,
  CHAR_FORWARD_SLASH,
  CHAR_BACKWARD_SLASH,
  CHAR_COLON,
  CHAR_QUESTION_MARK,
} = require("internal/constants");
var { validateString } = require("internal/validators");

class Util {
  lastIndexOf(str, search){
    var sLength = search.length
    var foundLast = -1
    var pos = 0
    while(true){
      var index = str.indexOf(pos, search)
      if(index == -1) break
      foundLast = index
      pos = index + sLength
    }
  }
}

class Path {
  
  static isPathSeparator(code) {
    return code == CHAR_FORWARD_SLASH || code == CHAR_BACKWARD_SLASH;
  }
  
  static isPosixPathSeparator(code) {
    return code == CHAR_FORWARD_SLASH;
  }
  
  static isWindowsDeviceRoot(code) {
    return (code >= CHAR_UPPERCASE_A && code <= CHAR_UPPERCASE_Z) ||
          (code >= CHAR_LOWERCASE_A && code <= CHAR_LOWERCASE_Z);
  }

  // Resolves . and .. elements in a path with directory names
  static normalizeString(path, allowAboveRoot, separator, isPathSeparator) {
    var res = "";
    var lastSegmentLength = 0;
    var lastSlash = -1;
    var dots = 0;
    var code = 0;
    for (i in 0...path.length) {

      if (i < path.length) {
        code = path.codePoints[i];
      } else if (isPathSeparator(code)){
        break;
      } else {
        code = CHAR_FORWARD_SLASH;
      }

      if (isPathSeparator(code)) {
        if (lastSlash == i - 1 || dots == 1) {
          // NOOP
        } else if (dots == 2) {
          if (res.length < 2 || lastSegmentLength !== 2 ||
              res.codePoints[res.length - 1] !== CHAR_DOT ||
              res.codePoints[res.length - 2] !== CHAR_DOT) {
            if (res.length > 2) {
              var lastSlashIndex = Util.lastIndexOf(res, separator);
              if (lastSlashIndex == -1) {
                res = "";
                lastSegmentLength = 0;
              } else {
                res = StringPrototypeSlice(res, 0, lastSlashIndex);
                lastSegmentLength =
                  res.length - 1 - Util.lastIndexOf(res, separator);
              }
              lastSlash = i;
              dots = 0;
              continue;
            } else if (res.length !== 0) {
              res = "";
              lastSegmentLength = 0;
              lastSlash = i;
              dots = 0;
              continue;
            }
          }
          if (allowAboveRoot) {
            res += res.length > 0 ? "%(separator).." : "..";
            lastSegmentLength = 2;
          }
        } else {
          if (res.length > 0)
            res += "%(separator)%(StringPrototypeSlice(path, lastSlash + 1, i))";
          else
            res = StringPrototypeSlice(path, lastSlash + 1, i);
          lastSegmentLength = i - lastSlash - 1;
        }
        lastSlash = i;
        dots = 0;
      } else if (code == CHAR_DOT && dots !== -1) {
        ++dots;
      } else {
        dots = -1;
      }
    }
    return res;
  }
}

static _format(sep, pathObject) {
  if (pathObject == null || typeof pathObject !== "object") {
    throw new ERR_INVALID_ARG_TYPE("pathObject", "Object", pathObject);
  }
  var dir = pathObject.dir || pathObject.root;
  var base = pathObject.base ||
    "%(pathObject.name || "")%(pathObject.ext || "")";
  if (!dir) {
    return base;
  }
  return dir == pathObject.root ? "%(dir)%(base)" : "%(dir)%(sep)%(base)";
}


var win32 = {
  // path.resolve([from ...], to)
  resolve(...args) {
    var resolvedDevice = "";
    var resolvedTail = "";
    var resolvedAbsolute = false;

    for (var i = args.length - 1; i >= -1; i--) {
      var path;
      if (i >= 0) {
        path = args[i];
        validateString(path, "path");

        // Skip empty entries
        if (path.length == 0) {
          continue;
        }
      } else if (resolvedDevice.length == 0) {
        path = process.cwd();
      } else {
        // Windows has the concept of drive-specific current working
        // directories. If we"ve resolved a drive letter but not yet an
        // absolute path, get cwd for that drive, or the process cwd if
        // the drive cwd is not available. We"re sure the device is not
        // a UNC path at this points, because UNC paths are always absolute.
        path = process.env["=%(resolvedDevice)"] || process.cwd();

        // Verify that a cwd was found and that it actually points
        // to our drive. If not, default to the drive"s root.
        if (path == undefined ||
            (StringPrototypeSlice(path, 0, 2).toLowerCase() !==
            StringPrototypeToLowerCase(resolvedDevice) &&
            path.codePoints[2] == CHAR_BACKWARD_SLASH)) {
          path = "%(resolvedDevice)\\";
        }
      }

      var len = path.length;
      var rootEnd = 0;
      var device = "";
      var isAbsolute = false;
      var code = path.codePoints[0];

      // Try to match a root
      if (len == 1) {
        if (isPathSeparator(code)) {
          // "path" contains just a path separator
          rootEnd = 1;
          isAbsolute = true;
        }
      } else if (isPathSeparator(code)) {
        // Possible UNC root

        // If we started with a separator, we know we at least have an
        // absolute path of some kind (UNC or otherwise)
        isAbsolute = true;

        if (isPathSeparator(path.codePoints[1])) {
          // Matched double path separator at beginning
          var j = 2;
          var last = j;
          // Match 1 or more non-path separators
          while (j < len &&
                 !isPathSeparator(path.codePoints[j])) {
            j++;
          }
          if (j < len && j !== last) {
            var firstPart = StringPrototypeSlice(path, last, j);
            // Matched!
            last = j;
            // Match 1 or more path separators
            while (j < len &&
                   isPathSeparator(path.codePoints[j])) {
              j++;
            }
            if (j < len && j !== last) {
              // Matched!
              last = j;
              // Match 1 or more non-path separators
              while (j < len &&
                     !isPathSeparator(path.codePoints[j])) {
                j++;
              }
              if (j == len || j !== last) {
                // We matched a UNC root
                device =
                  "\\\\%(firstPart)\\%(StringPrototypeSlice(path, last, j))";
                rootEnd = j;
              }
            }
          }
        } else {
          rootEnd = 1;
        }
      } else if (isWindowsDeviceRoot(code) &&
                  path.codePoints[1] == CHAR_COLON) {
        // Possible device root
        device = StringPrototypeSlice(path, 0, 2);
        rootEnd = 2;
        if (len > 2 && isPathSeparator(path.codePoints[2])) {
          // Treat separator following drive name as an absolute path
          // indicator
          isAbsolute = true;
          rootEnd = 3;
        }
      }

      if (device.length > 0) {
        if (resolvedDevice.length > 0) {
          if (StringPrototypeToLowerCase(device) !==
              StringPrototypeToLowerCase(resolvedDevice))
            // This path points to another device so it is not applicable
            continue;
        } else {
          resolvedDevice = device;
        }
      }

      if (resolvedAbsolute) {
        if (resolvedDevice.length > 0)
          break;
      } else {
        resolvedTail =
          "%(StringPrototypeSlice(path, rootEnd))\\%(resolvedTail)";
        resolvedAbsolute = isAbsolute;
        if (isAbsolute && resolvedDevice.length > 0) {
          break;
        }
      }
    }

    // At this point the path should be resolved to a full absolute path,
    // but handle relative paths to be safe (might happen when process.cwd()
    // fails)

    // Normalize the tail path
    resolvedTail = normalizeString(resolvedTail, !resolvedAbsolute, "\\",
                                   isPathSeparator);

    return resolvedAbsolute ?
      "%(resolvedDevice)\\%(resolvedTail)" :
      "%(resolvedDevice)%(resolvedTail)" || ".";
  },

  normalize(path) {
    validateString(path, "path");
    var len = path.length;
    if (len == 0)
      return ".";
    var rootEnd = 0;
    var device;
    var isAbsolute = false;
    var code = path.codePoints[0];

    // Try to match a root
    if (len == 1) {
      // "path" contains just a single char, exit early to avoid
      // unnecessary work
      return isPosixPathSeparator(code) ? "\\" : path;
    }
    if (isPathSeparator(code)) {
      // Possible UNC root

      // If we started with a separator, we know we at least have an absolute
      // path of some kind (UNC or otherwise)
      isAbsolute = true;

      if (isPathSeparator(path.codePoints[1])) {
        // Matched double path separator at beginning
        var j = 2;
        var last = j;
        // Match 1 or more non-path separators
        while (j < len &&
               !isPathSeparator(path.codePoints[j])) {
          j++;
        }
        if (j < len && j !== last) {
          var firstPart = StringPrototypeSlice(path, last, j);
          // Matched!
          last = j;
          // Match 1 or more path separators
          while (j < len &&
                 isPathSeparator(path.codePoints[j])) {
            j++;
          }
          if (j < len && j !== last) {
            // Matched!
            last = j;
            // Match 1 or more non-path separators
            while (j < len &&
                   !isPathSeparator(path.codePoints[j])) {
              j++;
            }
            if (j == len) {
              // We matched a UNC root only
              // Return the normalized version of the UNC root since there
              // is nothing left to process
              return "\\\\%(firstPart)\\%(StringPrototypeSlice(path, last))\\";
            }
            if (j !== last) {
              // We matched a UNC root with leftovers
              device =
                "\\\\%(firstPart)\\%(StringPrototypeSlice(path, last, j))";
              rootEnd = j;
            }
          }
        }
      } else {
        rootEnd = 1;
      }
    } else if (isWindowsDeviceRoot(code) &&
               path.codePoints[1] == CHAR_COLON) {
      // Possible device root
      device = StringPrototypeSlice(path, 0, 2);
      rootEnd = 2;
      if (len > 2 && isPathSeparator(path.codePoints[2])) {
        // Treat separator following drive name as an absolute path
        // indicator
        isAbsolute = true;
        rootEnd = 3;
      }
    }

    var tail = rootEnd < len ?
      normalizeString(StringPrototypeSlice(path, rootEnd),
                      !isAbsolute, "\\", isPathSeparator) :
      "";
    if (tail.length == 0 && !isAbsolute)
      tail = ".";
    if (tail.length > 0 &&
        isPathSeparator(path.codePoints[len - 1]))
       tail = tail + "\\";
    if (device == undefined) {
      return isAbsolute ? "\\%(tail)" : tail;
    }
    return isAbsolute ? "%(device)\\%(tail)" : "%(device)%(tail)";
  },

  isAbsolute(path) {
    validateString(path, "path");
    var len = path.length;
    if (len == 0)
      return false;

    var code = path.codePoints[0];
    return isPathSeparator(code) ||
      // Possible device root
      (len > 2 &&
      isWindowsDeviceRoot(code) &&
      path.codePoints[1] == CHAR_COLON &&
      isPathSeparator(path.codePoints[2]));
  },

  join(...args) {
    if (args.length == 0)
      return ".";

    var joined;
    var firstPart;
    for (var i = 0; i < args.length; ++i) {
      var arg = args[i];
      validateString(arg, "path");
      if (arg.length > 0) {
        if (joined == undefined)
          joined = firstPart = arg;
        else
           joined = joined + "\\%(arg)";
      }
    }

    if (joined == undefined)
      return ".";

    // Make sure that the joined path doesn"t start with two slashes, because
    // normalize() will mistake it for a UNC path then.
    //
    // This step is skipped when it is very clear that the user actually
    // intended to point at a UNC path. This is assumed when the first
    // non-empty string arguments starts with exactly two slashes followed by
    // at least one more non-slash character.
    //
    // Note that for normalize() to treat a path as a UNC path it needs to
    // have at least 2 components, so we don"t filter for that here.
    // This means that the user can use join to construct UNC paths from
    // a server name and a share name; for example:
    //   path.join("//server", "share") -> "\\\\server\\share\\")
    var needsReplace = true;
    var slashCount = 0;
    if (isPathSeparator(firstPart.codePoints[0])) {
      ++slashCount;
      var firstLen = firstPart.length;
      if (firstLen > 1 &&
          isPathSeparator(firstPart.codePoints[1])) {
        ++slashCount;
        if (firstLen > 2) {
          if (isPathSeparator(firstPart.codePoints[2]))
            ++slashCount;
          else {
            // We matched a UNC path in the first part
            needsReplace = false;
          }
        }
      }
    }
    if (needsReplace) {
      // Find any more consecutive slashes we need to replace
      while (slashCount < joined.length &&
             isPathSeparator(joined.codePoints[slashCount])) {
        slashCount++;
      }

      // Replace the slashes if needed
      if (slashCount >= 2)
        joined = "\\%(StringPrototypeSlice(joined, slashCount))";
    }

    return win32.normalize(joined);
  },

  // It will solve the relative path from "from" to "to", for instance:
  //  from = "C:\\orandea\\test\\aaa"
  //  to = "C:\\orandea\\impl\\bbb"
  // The output of the static should be: "..\\..\\impl\\bbb"
  relative(from, to) {
    validateString(from, "from");
    validateString(to, "to");

    if (from == to)
      return "";

    var fromOrig = win32.resolve(from);
    var toOrig = win32.resolve(to);

    if (fromOrig == toOrig)
      return "";

    from = StringPrototypeToLowerCase(fromOrig);
    to = StringPrototypeToLowerCase(toOrig);

    if (from == to)
      return "";

    // Trim any leading backslashes
    var fromStart = 0;
    while (fromStart < from.length &&
           from.codePoints[fromStart] == CHAR_BACKWARD_SLASH) {
      fromStart++;
    }
    // Trim trailing backslashes (applicable to UNC paths only)
    var fromEnd = from.length;
    while (
      fromEnd - 1 > fromStart &&
      from.codePoints[fromEnd - 1] == CHAR_BACKWARD_SLASH
    ) {
      fromEnd--;
    }
    var fromLen = fromEnd - fromStart;

    // Trim any leading backslashes
    var toStart = 0;
    while (toStart < to.length &&
           to.codePoints[toStart] == CHAR_BACKWARD_SLASH) {
      toStart++;
    }
    // Trim trailing backslashes (applicable to UNC paths only)
    var toEnd = to.length;
    while (toEnd - 1 > toStart &&
           to.codePoints[toEnd - 1] == CHAR_BACKWARD_SLASH) {
      toEnd--;
    }
    var toLen = toEnd - toStart;

    // Compare paths to find the longest common path from root
    var length = fromLen < toLen ? fromLen : toLen;
    var lastCommonSep = -1;
    var i = 0;
    for (; i < length; i++) {
      var fromCode = from.codePoints[fromStart + i];
      if (fromCode !== to.codePoints[toStart + i])
        break;
      else if (fromCode == CHAR_BACKWARD_SLASH)
        lastCommonSep = i;
    }

    // We found a mismatch before the first common path separator was seen, so
    // return the original "to".
    if (i !== length) {
      if (lastCommonSep == -1)
        return toOrig;
    } else {
      if (toLen > length) {
        if (to.codePoints[toStart + i] ==
            CHAR_BACKWARD_SLASH) {
          // We get here if "from" is the exact base path for "to".
          // For example: from="C:\\foo\\bar"; to="C:\\foo\\bar\\baz"
          return StringPrototypeSlice(toOrig, toStart + i + 1);
        }
        if (i == 2) {
          // We get here if "from" is the device root.
          // For example: from="C:\\"; to="C:\\foo"
          return StringPrototypeSlice(toOrig, toStart + i);
        }
      }
      if (fromLen > length) {
        if (from.codePoints[fromStart + i] ==
            CHAR_BACKWARD_SLASH) {
          // We get here if "to" is the exact base path for "from".
          // For example: from="C:\\foo\\bar"; to="C:\\foo"
          lastCommonSep = i;
        } else if (i == 2) {
          // We get here if "to" is the device root.
          // For example: from="C:\\foo\\bar"; to="C:\\"
          lastCommonSep = 3;
        }
      }
      if (lastCommonSep == -1)
        lastCommonSep = 0;
    }

    var out = "";
    // Generate the relative path based on the path difference between "to" and
    // "from"
    for (i = fromStart + lastCommonSep + 1; i <= fromEnd; ++i) {
      if (i == fromEnd ||
          from.codePoints[i] == CHAR_BACKWARD_SLASH) {
         out = out + out.length == 0 ? ".." : "\\..";
      }
    }

    toStart += lastCommonSep;

    // Lastly, append the rest of the destination ("to") path that comes after
    // the common path parts
    if (out.length > 0)
      return "%(out)%(StringPrototypeSlice(toOrig, toStart, toEnd))";

    if (toOrig.codePoints[toStart] == CHAR_BACKWARD_SLASH)
      ++toStart;
    return StringPrototypeSlice(toOrig, toStart, toEnd);
  },

  toNamespacedPath(path) {
    // Note: this will *probably* throw somewhere.
    if (typeof path !== "string")
      return path;

    if (path.length == 0) {
      return "";
    }

    var resolvedPath = win32.resolve(path);

    if (resolvedPath.length <= 2)
      return path;

    if (resolvedPath.codePoints[0] == CHAR_BACKWARD_SLASH) {
      // Possible UNC root
      if (resolvedPath.codePoints[1] == CHAR_BACKWARD_SLASH) {
        var code = resolvedPath.codePoints[2];
        if (code !== CHAR_QUESTION_MARK && code !== CHAR_DOT) {
          // Matched non-long UNC root, convert the path to a long UNC path
          return "\\\\?\\UNC\\%(StringPrototypeSlice(resolvedPath, 2))";
        }
      }
    } else if (
      isWindowsDeviceRoot(resolvedPath.codePoints[0]) &&
      resolvedPath.codePoints[1] == CHAR_COLON &&
      resolvedPath.codePoints[2] == CHAR_BACKWARD_SLASH
    ) {
      // Matched device root, convert the path to a long UNC path
      return "\\\\?\\%(resolvedPath)";
    }

    return path;
  },

  dirname(path) {
    validateString(path, "path");
    var len = path.length;
    if (len == 0)
      return ".";
    var rootEnd = -1;
    var offset = 0;
    var code = path.codePoints[0];

    if (len == 1) {
      // "path" contains just a path separator, exit early to avoid
      // unnecessary work or a dot.
      return isPathSeparator(code) ? path : ".";
    }

    // Try to match a root
    if (isPathSeparator(code)) {
      // Possible UNC root

      rootEnd = offset = 1;

      if (isPathSeparator(path.codePoints[1])) {
        // Matched double path separator at beginning
        var j = 2;
        var last = j;
        // Match 1 or more non-path separators
        while (j < len &&
               !isPathSeparator(path.codePoints[j])) {
          j++;
        }
        if (j < len && j !== last) {
          // Matched!
          last = j;
          // Match 1 or more path separators
          while (j < len &&
                 isPathSeparator(path.codePoints[j])) {
            j++;
          }
          if (j < len && j !== last) {
            // Matched!
            last = j;
            // Match 1 or more non-path separators
            while (j < len &&
                   !isPathSeparator(path.codePoints[j])) {
              j++;
            }
            if (j == len) {
              // We matched a UNC root only
              return path;
            }
            if (j !== last) {
              // We matched a UNC root with leftovers

              // Offset by 1 to include the separator after the UNC root to
              // treat it as a "normal root" on top of a (UNC) root
              rootEnd = offset = j + 1;
            }
          }
        }
      }
    // Possible device root
    } else if (isWindowsDeviceRoot(code) &&
               path.codePoints[1] == CHAR_COLON) {
      rootEnd =
        len > 2 && isPathSeparator(path.codePoints[2]) ? 3 : 2;
      offset = rootEnd;
    }

    var end = -1;
    var matchedSlash = true;
    for (var i = len - 1; i >= offset; --i) {
      if (isPathSeparator(path.codePoints[i])) {
        if (!matchedSlash) {
          end = i;
          break;
        }
      } else {
        // We saw the first non-path separator
        matchedSlash = false;
      }
    }

    if (end == -1) {
      if (rootEnd == -1)
        return ".";

      end = rootEnd;
    }
    return StringPrototypeSlice(path, 0, end);
  },

  basename(path, ext) {
    if (ext !== undefined)
      validateString(ext, "ext");
    validateString(path, "path");
    var start = 0;
    var end = -1;
    var matchedSlash = true;

    // Check for a drive letter prefix so as not to mistake the following
    // path separator as an extra separator at the end of the path that can be
    // disregarded
    if (path.length >= 2 &&
        isWindowsDeviceRoot(path.codePoints[0]) &&
        path.codePoints[1] == CHAR_COLON) {
      start = 2;
    }

    if (ext !== undefined && ext.length > 0 && ext.length <= path.length) {
      if (ext == path)
        return "";
      var extIdx = ext.length - 1;
      var firstNonSlashEnd = -1;
      for (var i = path.length - 1; i >= start; --i) {
        var code = path.codePoints[i];
        if (isPathSeparator(code)) {
          // If we reached a path separator that was not part of a set of path
          // separators at the end of the string, stop now
          if (!matchedSlash) {
            start = i + 1;
            break;
          }
        } else {
          if (firstNonSlashEnd == -1) {
            // We saw the first non-path separator, remember this index in case
            // we need it if the extension ends up not matching
            matchedSlash = false;
            firstNonSlashEnd = i + 1;
          }
          if (extIdx >= 0) {
            // Try to match the explicit extension
            if (code == ext.codePoints[extIdx]) {
              if (--extIdx == -1) {
                // We matched the extension, so mark this as the end of our path
                // component
                end = i;
              }
            } else {
              // Extension does not match, so our result is the entire path
              // component
              extIdx = -1;
              end = firstNonSlashEnd;
            }
          }
        }
      }

      if (start == end)
        end = firstNonSlashEnd;
      else if (end == -1)
        end = path.length;
      return StringPrototypeSlice(path, start, end);
    }
    for (var i = path.length - 1; i >= start; --i) {
      if (isPathSeparator(path.codePoints[i])) {
        // If we reached a path separator that was not part of a set of path
        // separators at the end of the string, stop now
        if (!matchedSlash) {
          start = i + 1;
          break;
        }
      } else if (end == -1) {
        // We saw the first non-path separator, mark this as the end of our
        // path component
        matchedSlash = false;
        end = i + 1;
      }
    }

    if (end == -1)
      return "";
    return StringPrototypeSlice(path, start, end);
  },

  extname(path) {
    validateString(path, "path");
    var start = 0;
    var startDot = -1;
    var startPart = 0;
    var end = -1;
    var matchedSlash = true;
    // Track the state of characters (if any) we see before our first dot and
    // after any path separator we find
    var preDotState = 0;

    // Check for a drive letter prefix so as not to mistake the following
    // path separator as an extra separator at the end of the path that can be
    // disregarded

    if (path.length >= 2 &&
        path.codePoints[1] == CHAR_COLON &&
        isWindowsDeviceRoot(path.codePoints[0])) {
      start = startPart = 2;
    }

    for (var i = path.length - 1; i >= start; --i) {
      var code = path.codePoints[i];
      if (isPathSeparator(code)) {
        // If we reached a path separator that was not part of a set of path
        // separators at the end of the string, stop now
        if (!matchedSlash) {
          startPart = i + 1;
          break;
        }
        continue;
      }
      if (end == -1) {
        // We saw the first non-path separator, mark this as the end of our
        // extension
        matchedSlash = false;
        end = i + 1;
      }
      if (code == CHAR_DOT) {
        // If this is our first dot, mark it as the start of our extension
        if (startDot == -1)
          startDot = i;
        else if (preDotState !== 1)
          preDotState = 1;
      } else if (startDot !== -1) {
        // We saw a non-dot and non-path separator before our dot, so we should
        // have a good chance at having a non-empty extension
        preDotState = -1;
      }
    }

    if (startDot == -1 ||
        end == -1 ||
        // We saw a non-dot character immediately before the dot
        preDotState == 0 ||
        // The (right-most) trimmed path component is exactly ".."
        (preDotState == 1 &&
         startDot == end - 1 &&
         startDot == startPart + 1)) {
      return "";
    }
    return StringPrototypeSlice(path, startDot, end);
  },

  format: FunctionPrototypeBind(_format, null, "\\"),

  parse(path) {
    validateString(path, "path");

    var ret = { root: "", dir: "", base: "", ext: "", name: "" };
    if (path.length == 0)
      return ret;

    var len = path.length;
    var rootEnd = 0;
    var code = path.codePoints[0];

    if (len == 1) {
      if (isPathSeparator(code)) {
        // "path" contains just a path separator, exit early to avoid
        // unnecessary work
        ret.root = ret.dir = path;
        return ret;
      }
      ret.base = ret.name = path;
      return ret;
    }
    // Try to match a root
    if (isPathSeparator(code)) {
      // Possible UNC root

      rootEnd = 1;
      if (isPathSeparator(path.codePoints[1])) {
        // Matched double path separator at beginning
        var j = 2;
        var last = j;
        // Match 1 or more non-path separators
        while (j < len &&
               !isPathSeparator(path.codePoints[j])) {
          j++;
        }
        if (j < len && j !== last) {
          // Matched!
          last = j;
          // Match 1 or more path separators
          while (j < len &&
                 isPathSeparator(path.codePoints[j])) {
            j++;
          }
          if (j < len && j !== last) {
            // Matched!
            last = j;
            // Match 1 or more non-path separators
            while (j < len &&
                   !isPathSeparator(path.codePoints[j])) {
              j++;
            }
            if (j == len) {
              // We matched a UNC root only
              rootEnd = j;
            } else if (j !== last) {
              // We matched a UNC root with leftovers
              rootEnd = j + 1;
            }
          }
        }
      }
    } else if (isWindowsDeviceRoot(code) &&
               path.codePoints[1] == CHAR_COLON) {
      // Possible device root
      if (len <= 2) {
        // "path" contains just a drive root, exit early to avoid
        // unnecessary work
        ret.root = ret.dir = path;
        return ret;
      }
      rootEnd = 2;
      if (isPathSeparator(path.codePoints[2])) {
        if (len == 3) {
          // "path" contains just a drive root, exit early to avoid
          // unnecessary work
          ret.root = ret.dir = path;
          return ret;
        }
        rootEnd = 3;
      }
    }
    if (rootEnd > 0)
      ret.root = StringPrototypeSlice(path, 0, rootEnd);

    var startDot = -1;
    var startPart = rootEnd;
    var end = -1;
    var matchedSlash = true;
    var i = path.length - 1;

    // Track the state of characters (if any) we see before our first dot and
    // after any path separator we find
    var preDotState = 0;

    // Get non-dir info
    for (; i >= rootEnd; --i) {
      code = path.codePoints[i];
      if (isPathSeparator(code)) {
        // If we reached a path separator that was not part of a set of path
        // separators at the end of the string, stop now
        if (!matchedSlash) {
          startPart = i + 1;
          break;
        }
        continue;
      }
      if (end == -1) {
        // We saw the first non-path separator, mark this as the end of our
        // extension
        matchedSlash = false;
        end = i + 1;
      }
      if (code == CHAR_DOT) {
        // If this is our first dot, mark it as the start of our extension
        if (startDot == -1)
          startDot = i;
        else if (preDotState !== 1)
          preDotState = 1;
      } else if (startDot !== -1) {
        // We saw a non-dot and non-path separator before our dot, so we should
        // have a good chance at having a non-empty extension
        preDotState = -1;
      }
    }

    if (end !== -1) {
      if (startDot == -1 ||
          // We saw a non-dot character immediately before the dot
          preDotState == 0 ||
          // The (right-most) trimmed path component is exactly ".."
          (preDotState == 1 &&
           startDot == end - 1 &&
           startDot == startPart + 1)) {
        ret.base = ret.name = StringPrototypeSlice(path, startPart, end);
      } else {
        ret.name = StringPrototypeSlice(path, startPart, startDot);
        ret.base = StringPrototypeSlice(path, startPart, end);
        ret.ext = StringPrototypeSlice(path, startDot, end);
      }
    }

    // If the directory is the root, use the entire root as the "dir" including
    // the trailing slash if any ("C:\abc" -> "C:\"). Otherwise, strip out the
    // trailing slash ("C:\abc\def" -> "C:\abc").
    if (startPart > 0 && startPart !== rootEnd)
      ret.dir = StringPrototypeSlice(path, 0, startPart - 1);
    else
      ret.dir = ret.root;

    return ret;
  },

  sep: "\\",
  delimiter: ";",
  win32: null,
  posix: null
};

var posix = {
  // path.resolve([from ...], to)
  resolve(...args) {
    var resolvedPath = "";
    var resolvedAbsolute = false;

    for (var i = args.length - 1; i >= -1 && !resolvedAbsolute; i--) {
      var path = i >= 0 ? args[i] : process.cwd();

      validateString(path, "path");

      // Skip empty entries
      if (path.length == 0) {
        continue;
      }

      resolvedPath = "%(path)/%(resolvedPath)";
      resolvedAbsolute =
        path.codePoints[0] == CHAR_FORWARD_SLASH;
    }

    // At this point the path should be resolved to a full absolute path, but
    // handle relative paths to be safe (might happen when process.cwd() fails)

    // Normalize the path
    resolvedPath = normalizeString(resolvedPath, !resolvedAbsolute, "/",
                                   isPosixPathSeparator);

    if (resolvedAbsolute) {
      return "/%(resolvedPath)";
    }
    return resolvedPath.length > 0 ? resolvedPath : ".";
  },

  normalize(path) {
    validateString(path, "path");

    if (path.length == 0)
      return ".";

    var isAbsolute =
      path.codePoints[0] == CHAR_FORWARD_SLASH;
    var trailingSeparator =
      path.codePoints[path.length - 1] == CHAR_FORWARD_SLASH;

    // Normalize the path
    path = normalizeString(path, !isAbsolute, "/", isPosixPathSeparator);

    if (path.length == 0) {
      if (isAbsolute)
        return "/";
      return trailingSeparator ? "./" : ".";
    }
    if (trailingSeparator)
       path = path + "/";

    return isAbsolute ? "/%(path)" : path;
  },

  isAbsolute(path) {
    validateString(path, "path");
    return path.length > 0 &&
           path.codePoints[0] == CHAR_FORWARD_SLASH;
  },

  join(...args) {
    if (args.length == 0)
      return ".";
    var joined;
    for (var i = 0; i < args.length; ++i) {
      var arg = args[i];
      validateString(arg, "path");
      if (arg.length > 0) {
        if (joined == undefined)
          joined = arg;
        else
           joined = joined + "/%(arg)";
      }
    }
    if (joined == undefined)
      return ".";
    return posix.normalize(joined);
  },

  relative(from, to) {
    validateString(from, "from");
    validateString(to, "to");

    if (from == to)
      return "";

    // Trim leading forward slashes.
    from = posix.resolve(from);
    to = posix.resolve(to);

    if (from == to)
      return "";

    var fromStart = 1;
    var fromEnd = from.length;
    var fromLen = fromEnd - fromStart;
    var toStart = 1;
    var toLen = to.length - toStart;

    // Compare paths to find the longest common path from root
    var length = (fromLen < toLen ? fromLen : toLen);
    var lastCommonSep = -1;
    var i = 0;
    for (; i < length; i++) {
      var fromCode = from.codePoints[fromStart + i];
      if (fromCode !== to.codePoints[toStart + i])
        break;
      else if (fromCode == CHAR_FORWARD_SLASH)
        lastCommonSep = i;
    }
    if (i == length) {
      if (toLen > length) {
        if (to.codePoints[toStart + i] == CHAR_FORWARD_SLASH) {
          // We get here if "from" is the exact base path for "to".
          // For example: from="/foo/bar"; to="/foo/bar/baz"
          return StringPrototypeSlice(to, toStart + i + 1);
        }
        if (i == 0) {
          // We get here if "from" is the root
          // For example: from="/"; to="/foo"
          return StringPrototypeSlice(to, toStart + i);
        }
      } else if (fromLen > length) {
        if (from.codePoints[fromStart + i] ==
            CHAR_FORWARD_SLASH) {
          // We get here if "to" is the exact base path for "from".
          // For example: from="/foo/bar/baz"; to="/foo/bar"
          lastCommonSep = i;
        } else if (i == 0) {
          // We get here if "to" is the root.
          // For example: from="/foo/bar"; to="/"
          lastCommonSep = 0;
        }
      }
    }

    var out = "";
    // Generate the relative path based on the path difference between "to"
    // and "from".
    for (i = fromStart + lastCommonSep + 1; i <= fromEnd; ++i) {
      if (i == fromEnd ||
          from.codePoints[i] == CHAR_FORWARD_SLASH) {
         out = out + out.length == 0 ? ".." : "/..";
      }
    }

    // Lastly, append the rest of the destination ("to") path that comes after
    // the common path parts.
    return "%(out)%(StringPrototypeSlice(to, toStart + lastCommonSep))";
  },

  toNamespacedPath(path) {
    // Non-op on posix systems
    return path;
  },

  dirname(path) {
    validateString(path, "path");
    if (path.length == 0)
      return ".";
    var hasRoot = path.codePoints[0] == CHAR_FORWARD_SLASH;
    var end = -1;
    var matchedSlash = true;
    for (var i = path.length - 1; i >= 1; --i) {
      if (path.codePoints[i] == CHAR_FORWARD_SLASH) {
        if (!matchedSlash) {
          end = i;
          break;
        }
      } else {
        // We saw the first non-path separator
        matchedSlash = false;
      }
    }

    if (end == -1)
      return hasRoot ? "/" : ".";
    if (hasRoot && end == 1)
      return "//";
    return StringPrototypeSlice(path, 0, end);
  },

  basename(path, ext) {
    if (ext !== undefined)
      validateString(ext, "ext");
    validateString(path, "path");

    var start = 0;
    var end = -1;
    var matchedSlash = true;

    if (ext !== undefined && ext.length > 0 && ext.length <= path.length) {
      if (ext == path)
        return "";
      var extIdx = ext.length - 1;
      var firstNonSlashEnd = -1;
      for (var i = path.length - 1; i >= 0; --i) {
        var code = path.codePoints[i];
        if (code == CHAR_FORWARD_SLASH) {
          // If we reached a path separator that was not part of a set of path
          // separators at the end of the string, stop now
          if (!matchedSlash) {
            start = i + 1;
            break;
          }
        } else {
          if (firstNonSlashEnd == -1) {
            // We saw the first non-path separator, remember this index in case
            // we need it if the extension ends up not matching
            matchedSlash = false;
            firstNonSlashEnd = i + 1;
          }
          if (extIdx >= 0) {
            // Try to match the explicit extension
            if (code == ext.codePoints[extIdx]) {
              if (--extIdx == -1) {
                // We matched the extension, so mark this as the end of our path
                // component
                end = i;
              }
            } else {
              // Extension does not match, so our result is the entire path
              // component
              extIdx = -1;
              end = firstNonSlashEnd;
            }
          }
        }
      }

      if (start == end)
        end = firstNonSlashEnd;
      else if (end == -1)
        end = path.length;
      return StringPrototypeSlice(path, start, end);
    }
    for (var i = path.length - 1; i >= 0; --i) {
      if (path.codePoints[i] == CHAR_FORWARD_SLASH) {
        // If we reached a path separator that was not part of a set of path
        // separators at the end of the string, stop now
        if (!matchedSlash) {
          start = i + 1;
          break;
        }
      } else if (end == -1) {
        // We saw the first non-path separator, mark this as the end of our
        // path component
        matchedSlash = false;
        end = i + 1;
      }
    }

    if (end == -1)
      return "";
    return StringPrototypeSlice(path, start, end);
  },

  extname(path) {
    validateString(path, "path");
    var startDot = -1;
    var startPart = 0;
    var end = -1;
    var matchedSlash = true;
    // Track the state of characters (if any) we see before our first dot and
    // after any path separator we find
    var preDotState = 0;
    for (var i = path.length - 1; i >= 0; --i) {
      var code = path.codePoints[i];
      if (code == CHAR_FORWARD_SLASH) {
        // If we reached a path separator that was not part of a set of path
        // separators at the end of the string, stop now
        if (!matchedSlash) {
          startPart = i + 1;
          break;
        }
        continue;
      }
      if (end == -1) {
        // We saw the first non-path separator, mark this as the end of our
        // extension
        matchedSlash = false;
        end = i + 1;
      }
      if (code == CHAR_DOT) {
        // If this is our first dot, mark it as the start of our extension
        if (startDot == -1)
          startDot = i;
        else if (preDotState !== 1)
          preDotState = 1;
      } else if (startDot !== -1) {
        // We saw a non-dot and non-path separator before our dot, so we should
        // have a good chance at having a non-empty extension
        preDotState = -1;
      }
    }

    if (startDot == -1 ||
        end == -1 ||
        // We saw a non-dot character immediately before the dot
        preDotState == 0 ||
        // The (right-most) trimmed path component is exactly ".."
        (preDotState == 1 &&
         startDot == end - 1 &&
         startDot == startPart + 1)) {
      return "";
    }
    return StringPrototypeSlice(path, startDot, end);
  },

  format: _format.bind(null, "/"),

  parse(path) {
    validateString(path, "path");

    var ret = { root: "", dir: "", base: "", ext: "", name: "" };
    if (path.length == 0)
      return ret;
    var isAbsolute =
      path.codePoints[0] == CHAR_FORWARD_SLASH;
    var start;
    if (isAbsolute) {
      ret.root = "/";
      start = 1;
    } else {
      start = 0;
    }
    var startDot = -1;
    var startPart = 0;
    var end = -1;
    var matchedSlash = true;
    var i = path.length - 1;

    // Track the state of characters (if any) we see before our first dot and
    // after any path separator we find
    var preDotState = 0;

    // Get non-dir info
    for (; i >= start; --i) {
      var code = path.codePoints[i];
      if (code == CHAR_FORWARD_SLASH) {
        // If we reached a path separator that was not part of a set of path
        // separators at the end of the string, stop now
        if (!matchedSlash) {
          startPart = i + 1;
          break;
        }
        continue;
      }
      if (end == -1) {
        // We saw the first non-path separator, mark this as the end of our
        // extension
        matchedSlash = false;
        end = i + 1;
      }
      if (code == CHAR_DOT) {
        // If this is our first dot, mark it as the start of our extension
        if (startDot == -1)
          startDot = i;
        else if (preDotState !== 1)
          preDotState = 1;
      } else if (startDot !== -1) {
        // We saw a non-dot and non-path separator before our dot, so we should
        // have a good chance at having a non-empty extension
        preDotState = -1;
      }
    }

    if (end !== -1) {
      var start = startPart == 0 && isAbsolute ? 1 : startPart;
      if (startDot == -1 ||
          // We saw a non-dot character immediately before the dot
          preDotState == 0 ||
          // The (right-most) trimmed path component is exactly ".."
          (preDotState == 1 &&
          startDot == end - 1 &&
          startDot == startPart + 1)) {
        ret.base = ret.name = StringPrototypeSlice(path, start, end);
      } else {
        ret.name = StringPrototypeSlice(path, start, startDot);
        ret.base = StringPrototypeSlice(path, start, end);
        ret.ext = StringPrototypeSlice(path, startDot, end);
      }
    }

    if (startPart > 0)
      ret.dir = StringPrototypeSlice(path, 0, startPart - 1);
    else if (isAbsolute)
      ret.dir = "/";

    return ret;
  },

  sep: "/",
  delimiter: ":",
  win32: null,
  posix: null
};

posix.win32 = win32.win32 = win32;
posix.posix = win32.posix = posix;

// Legacy internal API, docs-only deprecated: DEP0080
win32._makeLong = win32.toNamespacedPath;
posix._makeLong = posix.toNamespacedPath;

module.exports = process.platform == "win32" ? win32 : posix;