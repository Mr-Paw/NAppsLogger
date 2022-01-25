# NAppsLogger

### An easy to use logger for your app

## Usage

### Configuration: 

```swift
import NAppsLogger


let logger = NLogger()
logger.writers = [ConsoleLogWriter() /* NAppsLogger has ConsoleLogWriter and FileLogWriter, you can also create your own custom writer */] // by default there're `ConsoleLogWriter()`
logger.levels = .all // more info in documentation, by default there's `.all`
```

### Logging:

```swift
let logger = <#your NLogger#>
logger.send(<#your message#>, type: <#NLogger.LogType#>) // message can be any type
```


### Creating your own Custom log writer:

```swift
struct CustomLogWriter: NLogWriter {
    var executor: LogExecutable
    
    var prefix: LogPrefix
    
    func write(_ message: String) {
        // do something with log message
    }
    
    init(
      <#your params#>
      prefix: LogPrefix = .all,
      executor: LogExecutionType = .sync(lock: NSRecursiveLock())
    ) {
       <#your param setup#>
      self.prefix = prefix
      self.executor = executor
    }
}
```

Then:

```swift
let logger = <#your NLogger#>
let customWriter = // init your writer here
logger.writers = [customWriter] // you can pass some addictional writers
```

### Setting Log Levels

```swift
let logger = <#your NLogger#>
logger.levels = // pass NLogger.LogType
```

## Documentation

Documentation is available as `.doccarchive` (Xcode 13+ readable) at releases page
