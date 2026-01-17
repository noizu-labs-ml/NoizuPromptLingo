
# npl/instructing/alg.md
---
# Algorithm Specification Language
Structured notation for defining algorithms, computational processes, and procedural logic through specialized fence blocks.

## Syntax
```syntax
```alg
[algorithm specification]
```

```alg-pseudo
[pseudocode implementation]
```

```alg-<language>
[language-specific algorithm]
```
```

## Purpose
Algorithm specification language provides formal notation for expressing computational logic, step-by-step procedures, and algorithmic thinking patterns in structured, readable formats.

## Usage
Use alg-speak when you need to:
- Define precise computational procedures
- Specify algorithm implementations in pseudocode
- Document complex logic flows
- Provide language-specific algorithm variants

## Algorithm Fence Types

### General Algorithm (`alg`)
```example
```alg
Algorithm: FindMaximum(array A)
1. max ← A[0]
2. for i = 1 to length(A) - 1 do
3.   if A[i] > max then
4.     max ← A[i]
5.   end if
6. end for
7. return max
```
```

### Pseudocode Algorithm (`alg-pseudo`)
```example
```alg-pseudo
PROCEDURE BinarySearch(array, target):
  left = 0
  right = array.length - 1
  
  WHILE left <= right:
    mid = (left + right) / 2
    IF array[mid] = target:
      RETURN mid
    ELSE IF array[mid] < target:
      left = mid + 1
    ELSE:
      right = mid - 1
    END IF
  END WHILE
  
  RETURN -1
```
```

### Language-Specific Algorithms
```example
```alg-python
def quicksort(arr):
    if len(arr) <= 1:
        return arr
    pivot = arr[len(arr) // 2]
    left = [x for x in arr if x < pivot]
    middle = [x for x in arr if x == pivot]
    right = [x for x in arr if x > pivot]
    return quicksort(left) + middle + quicksort(right)
```
```

## Notation Conventions

### Assignment and Operations
- Assignment: `variable ← value` or `variable = value`
- Comparison: `=`, `≠`, `<`, `>`, `≤`, `≥`
- Logic: `AND`, `OR`, `NOT`
- Mathematics: `+`, `-`, `×`, `÷`, `mod`

### Control Structures
- Conditionals: `IF...THEN...ELSE...END IF`
- Loops: `FOR...TO...DO...END FOR`, `WHILE...DO...END WHILE`
- Procedures: `PROCEDURE name(parameters)...END PROCEDURE`

### Mathematical Notation
- Summation: `∑(expression)`
- Set operations: `A ∪ B`, `A ∩ B`
- Logic operators: `∀`, `∃`, `⟹`, `⟺`

## Advanced Patterns

### Recursive Algorithms
```example
```alg
Algorithm: Fibonacci(n)
1. if n ≤ 1 then
2.   return n
3. else
4.   return Fibonacci(n-1) + Fibonacci(n-2)
5. end if
```
```

### Data Structure Operations
```example
```alg-pseudo
PROCEDURE TreeTraversal(node):
  IF node ≠ null:
    PRINT node.value
    TreeTraversal(node.left)
    TreeTraversal(node.right)
  END IF
```
```

## Complexity Analysis
Include time and space complexity when relevant:
```example
```alg
Algorithm: LinearSearch(array A, target x)
// Time Complexity: O(n)
// Space Complexity: O(1)
1. for i = 0 to length(A) - 1 do
2.   if A[i] = x then
3.     return i
4.   end if
5. end for
6. return -1
```
```

## See Also
- `./.claude/npl/fences/alg.md` - Algorithm fence block specifications
- `./.claude/npl/fences/alg-pseudo.md` - Pseudocode formatting conventions
- `./.claude/npl/instructing/symbolic-logic.md` - Symbolic logic representations
- `./.claude/npl/syntax/logic-operators.md` - Mathematical and logical operators
* * *

# npl/instructing/alg/flowchart.md
---
# Flowchart Representations
Visual algorithm specification using flowchart diagrams and Mermaid syntax for algorithm flow representation.

## Syntax
`alg-flowchart` fence type or `mermaid flowchart` for visual algorithm representations

## Purpose
Represent algorithm logic flow using standardized flowchart symbols and visual connections to illustrate decision points, processes, and data flow in algorithmic sequences.

## Usage
Use flowchart representations when visual clarity of algorithm flow is important, for complex decision trees, or when communicating algorithms to stakeholders who prefer visual documentation.

## Examples

### Basic Decision Flow
```alg-flowchart
mermaid
flowchart TD
    A[Start] --> B[Get User Input]
    B --> C{Input Valid?}
    C -->|Yes| D[Process Input]
    C -->|No| E[Show Error Message]
    D --> F[Display Result]
    E --> B
    F --> G[End]
```

### Loop Structure
```alg-flowchart
mermaid
flowchart TD
    A[Start] --> B[Initialize counter = 0]
    B --> C[Initialize sum = 0]
    C --> D{counter < array.length?}
    D -->|Yes| E[Add array[counter] to sum]
    E --> F[Increment counter]
    F --> D
    D -->|No| G[Return sum]
    G --> H[End]
```

### Complex Algorithm with Multiple Paths
```alg-flowchart
mermaid
flowchart TD
    A[Start: User Login] --> B[Get Credentials]
    B --> C{Valid Format?}
    C -->|No| D[Show Format Error]
    D --> B
    C -->|Yes| E[Check Database]
    E --> F{User Exists?}
    F -->|No| G[Show User Not Found]
    G --> B
    F -->|Yes| H{Password Correct?}
    H -->|No| I[Increment Failed Attempts]
    I --> J{Attempts < 3?}
    J -->|Yes| K[Show Password Error]
    K --> B
    J -->|No| L[Lock Account]
    L --> M[Show Account Locked]
    M --> N[End]
    H -->|Yes| O[Generate Session Token]
    O --> P[Redirect to Dashboard]
    P --> N
```

### Nested Decision Structure
```alg-flowchart
mermaid
flowchart TD
    A[Start] --> B[Read User Role]
    B --> C{Role = Admin?}
    C -->|Yes| D[Load Admin Panel]
    C -->|No| E{Role = Manager?}
    E -->|Yes| F[Load Manager Dashboard]
    E -->|No| G{Role = User?}
    G -->|Yes| H[Load User Interface]
    G -->|No| I[Load Guest View]
    D --> J[End]
    F --> J
    H --> J
    I --> J
```

## Standard Flowchart Symbols

### Process Symbols
- **Rectangle**: Process or action step
- **Diamond**: Decision point (yes/no, true/false)
- **Oval**: Start/End terminals
- **Circle**: Connector or junction point
- **Parallelogram**: Input/Output operations

### Flow Connections
- **Solid Arrow**: Normal flow direction
- **Dashed Arrow**: Alternative or exception flow
- **Labeled Arrows**: Condition indicators (Yes/No, True/False)

## Mermaid Flowchart Syntax

### Basic Elements
```syntax
flowchart TD
    A[Process Box]
    B{Decision Diamond}
    C((Circle Node))
    D[/Input Output/]
    E[[Subroutine]]
    F[(Database)]
```

### Connection Types
```syntax
A --> B    // Solid arrow
A -.-> B   // Dotted arrow
A ==> B    // Thick arrow
A -- text --> B  // Arrow with text
A -->|label| B   // Arrow with label
```

### Styling Options
```syntax
classDef processClass fill:#e1f5fe
classDef decisionClass fill:#fff3e0
classDef errorClass fill:#ffebee

class A,D processClass
class B decisionClass
class E errorClass
```

## Parameters
- **Direction**: `TD` (top-down), `LR` (left-right), `BT` (bottom-top), `RL` (right-left)
- **Node Shapes**: Rectangle `[]`, Diamond `{}`, Circle `()`, Parallelogram `/\`
- **Connection Labels**: Text descriptions for flow conditions

* * *

# npl/instructing/alg/javascript.md
---
# JavaScript Algorithm Syntax
JavaScript-specific algorithm specification and implementation patterns within NPL framework.

## Syntax
`alg-javascript` or `alg-js` fence type for JavaScript algorithm implementations

## Purpose
Specify algorithms using modern JavaScript syntax with emphasis on ES6+ features, TypeScript compatibility, and functional programming patterns for web and Node.js environments.

## Usage
Use `alg-javascript` fences when providing JavaScript-specific algorithm implementations, demonstrating modern ES6+ features, or when targeting web/Node.js environments with JavaScript best practices.

## Examples

### Basic Algorithm with Modern Syntax
```alg-javascript
/**
 * Calculate total cost including tax for a list of items
 * @param {Array<{price: number}>} items - Array of item objects with price property
 * @param {number} taxRate - Tax rate as decimal (e.g., 0.08 for 8%)
 * @returns {number} Total cost including tax
 */
function calculateTotal(items, taxRate) {
    const total = items.reduce((sum, item) => sum + item.price, 0);
    const taxAmount = total * taxRate;
    return total + taxAmount;
}

// Arrow function alternative
const calculateTotalArrow = (items, taxRate) => {
    const total = items.reduce((sum, item) => sum + item.price, 0);
    return total + (total * taxRate);
};
```

### Async/Await and Error Handling
```alg-javascript
/**
 * Process user input with validation and async operations
 * @param {string|null} inputData - User input string
 * @returns {Promise<string>} Processed result or error message
 * @throws {Error} When input format is invalid
 */
async function processUserInput(inputData) {
    if (!inputData) {
        return "Empty input error";
    }
    
    if (!isValidInput(inputData)) {
        throw new Error("Invalid input format");
    }
    
    try {
        const result = await processInputAsync(inputData);
        return `Success: ${result}`;
    } catch (error) {
        return `Processing error: ${error.message}`;
    }
}

const isValidInput = (data) => data?.trim()?.length > 0;

const processInputAsync = async (data) => {
    // Simulate async operation
    return new Promise((resolve, reject) => {
        setTimeout(() => {
            if (data.includes('error')) {
                reject(new Error('Simulated processing error'));
            } else {
                resolve(`Processed: ${data.toUpperCase()}`);
            }
        }, 100);
    });
};
```

### Array and Object Manipulation
```alg-javascript
/**
 * Find maximum value in array using modern methods
 * @param {number[]} array - Array of numeric values
 * @returns {number} Maximum value in array
 * @throws {Error} When array is empty
 */
const findMaxValue = (array) => {
    if (!Array.isArray(array) || array.length === 0) {
        throw new Error("Cannot find max of empty array");
    }
    
    return Math.max(...array);
};

/**
 * Generate Fibonacci sequence using generator function
 * @param {number} n - Number of Fibonacci terms to generate
 * @yields {number} Next Fibonacci number in sequence
 */
function* fibonacciGenerator(n) {
    let [a, b] = [0, 1];
    for (let i = 0; i < n; i++) {
        yield a;
        [a, b] = [b, a + b];
    }
}

// Usage with destructuring and spread
const firstTenFib = [...fibonacciGenerator(10)];
```

### Object-Oriented Algorithms
```alg-javascript
/**
 * Graph algorithms implementation using ES6 classes
 */
class GraphAlgorithms {
    /**
     * Breadth-first search pathfinding
     * @param {Object} graph - Adjacency list representation
     * @param {*} start - Starting node
     * @param {*} target - Target node
     * @returns {Array|null} Path from start to target, or null if no path exists
     */
    static breadthFirstSearch(graph, start, target) {
        if (start === target) return [start];
        
        const queue = [[start, [start]]];
        const visited = new Set([start]);
        
        while (queue.length > 0) {
            const [current, path] = queue.shift();
            
            for (const neighbor of (graph[current] || [])) {
                if (neighbor === target) {
                    return [...path, neighbor];
                }
                
                if (!visited.has(neighbor)) {
                    visited.add(neighbor);
                    queue.push([neighbor, [...path, neighbor]]);
                }
            }
        }
        
        return null;
    }
    
    /**
     * Dijkstra's shortest path algorithm
     * @param {Object} graph - Weighted adjacency list
     * @param {*} start - Starting node
     * @returns {Object} Object mapping nodes to shortest distances
     */
    static dijkstraShortestPath(graph, start) {
        const distances = new Map();
        const heap = [[0, start]];
        const visited = new Set();
        
        // Initialize distances
        Object.keys(graph).forEach(node => {
            distances.set(node, node === start ? 0 : Infinity);
        });
        
        while (heap.length > 0) {
            heap.sort((a, b) => a[0] - b[0]); // Simple heap simulation
            const [currentDist, current] = heap.shift();
            
            if (visited.has(current)) continue;
            visited.add(current);
            
            for (const [neighbor, weight] of Object.entries(graph[current] || {})) {
                const distance = currentDist + weight;
                
                if (distance < distances.get(neighbor)) {
                    distances.set(neighbor, distance);
                    heap.push([distance, neighbor]);
                }
            }
        }
        
        return Object.fromEntries(distances);
    }
}
```

### Functional Programming Patterns
```alg-javascript
/**
 * Merge sort implementation using functional approach
 * @param {number[]} arr - Array of numbers to sort
 * @returns {number[]} Sorted array
 */
const mergeSort = (arr) => {
    if (arr.length <= 1) return arr;
    
    const mid = Math.floor(arr.length / 2);
    const left = mergeSort(arr.slice(0, mid));
    const right = mergeSort(arr.slice(mid));
    
    return merge(left, right);
};

const merge = (left, right) => {
    const result = [];
    let [i, j] = [0, 0];
    
    while (i < left.length && j < right.length) {
        if (left[i] <= right[j]) {
            result.push(left[i++]);
        } else {
            result.push(right[j++]);
        }
    }
    
    return [...result, ...left.slice(i), ...right.slice(j)];
};

// Pipeline pattern for data processing
const processData = (data) => 
    data
        .filter(item => item.active)
        .map(item => ({ ...item, processed: true }))
        .sort((a, b) => a.priority - b.priority)
        .reduce((acc, item) => ({ ...acc, [item.id]: item }), {});
```

### TypeScript-Compatible Patterns
```alg-javascript
/**
 * Type-aware algorithm implementation (JavaScript with JSDoc for TypeScript compatibility)
 * @template T
 * @param {T[]} items - Array of items to process
 * @param {(item: T) => boolean} predicate - Filtering predicate
 * @param {(item: T) => any} transform - Transformation function
 * @returns {any[]} Processed items
 */
const processItems = (items, predicate, transform) => {
    return items
        .filter(predicate)
        .map(transform);
};

/**
 * Generic comparison function
 * @template T
 * @param {T} a - First item
 * @param {T} b - Second item
 * @param {keyof T} key - Property to compare
 * @returns {number} Comparison result
 */
const compareBy = (a, b, key) => {
    if (a[key] < b[key]) return -1;
    if (a[key] > b[key]) return 1;
    return 0;
};
```

## JavaScript-Specific Conventions

### Modern ES6+ Features
- Use `const`/`let` instead of `var`
- Prefer arrow functions for simple operations
- Use template literals for string interpolation
- Leverage destructuring assignment
- Use spread operator for array/object operations

### Async Operations
- Use `async/await` for Promise handling
- Implement proper error handling with try-catch
- Use Promise.all() for concurrent operations
- Consider Promise.race() for timeout scenarios

### Functional Programming
- Prefer immutable operations
- Use array methods (map, filter, reduce)
- Implement pure functions when possible
- Use function composition for complex transformations

### Performance Considerations
- Use Set/Map for O(1) lookups
- Consider typed arrays for numeric operations
- Implement lazy evaluation with generators
- Use requestAnimationFrame for UI-heavy algorithms

## Parameters
- **JSDoc Comments**: Required for function documentation
- **Error Handling**: Include try-catch for async operations
- **Type Safety**: Use JSDoc types or TypeScript patterns
- **Browser/Node Compatibility**: Consider target environment

* * *

# npl/instructing/alg/pseudo.md
---
# Pseudocode Conventions
Standardized pseudocode formatting and conventions for algorithm specification in NPL framework.

## Syntax
`alg-pseudo` fence type for pseudocode algorithm blocks

## Purpose
Define algorithms using structured, language-agnostic pseudocode that clearly communicates logic flow and operations without implementation-specific syntax constraints.

## Usage
Use `alg-pseudo` fences when specifying algorithms that need to be understandable across different programming contexts or when the focus should be on logic rather than syntax.

## Examples

### Basic Algorithm Structure
```alg-pseudo
ALGORITHM calculateTotal(items, taxRate)
BEGIN
    total ← 0
    FOR each item IN items DO
        total ← total + item.price
    END FOR
    
    taxAmount ← total × taxRate
    finalTotal ← total + taxAmount
    
    RETURN finalTotal
END
```

### Control Flow Structures
```alg-pseudo
ALGORITHM processUserInput(input)
BEGIN
    IF input IS NOT empty THEN
        IF input IS valid THEN
            result ← processInput(input)
            RETURN result
        ELSE
            RETURN "Invalid input error"
        END IF
    ELSE
        RETURN "Empty input error"
    END IF
END
```

### Loop Constructs
```alg-pseudo
ALGORITHM findMaxValue(array)
BEGIN
    max ← array[0]
    index ← 1
    
    WHILE index < length(array) DO
        IF array[index] > max THEN
            max ← array[index]
        END IF
        index ← index + 1
    END WHILE
    
    RETURN max
END
```

## Conventions

### Variable Assignment
- Use `←` for assignment operations
- Use `=` for equality comparisons
- Use `:=` for initialization when needed

### Control Structures
- **Conditionals**: `IF...THEN...ELSE...END IF`
- **Loops**: `FOR...DO...END FOR`, `WHILE...DO...END WHILE`, `REPEAT...UNTIL`
- **Functions**: `ALGORITHM name(parameters)...BEGIN...END`

### Operations
- Mathematical: `+`, `-`, `×`, `÷`, `MOD`
- Logical: `AND`, `OR`, `NOT`
- Comparison: `=`, `≠`, `<`, `>`, `≤`, `≥`

### Data Structures
- Arrays: `array[index]`, `length(array)`
- Objects: `object.property`
- Collections: `add(item)`, `remove(item)`, `contains(item)`

## Parameters
- **BEGIN/END**: Algorithm block boundaries
- **INPUT/OUTPUT**: Explicit parameter and return specifications
- **PRECONDITION/POSTCONDITION**: Algorithm constraints and guarantees

* * *

# npl/instructing/alg/python.md
---
# Python Algorithm Syntax
Python-specific algorithm specification and implementation patterns within NPL framework.

## Syntax
`alg-python` fence type for Python algorithm implementations

## Purpose
Specify algorithms using Python syntax with emphasis on clarity, type hints, and modern Python conventions for algorithm documentation and implementation guidance.

## Usage
Use `alg-python` fences when providing Python-specific algorithm implementations, when type safety is important, or when demonstrating Python best practices for algorithmic solutions.

## Examples

### Basic Algorithm with Type Hints
```alg-python
def calculate_total(items: list[dict], tax_rate: float) -> float:
    """Calculate total cost including tax for a list of items.
    
    Args:
        items: List of item dictionaries with 'price' keys
        tax_rate: Tax rate as decimal (e.g., 0.08 for 8%)
        
    Returns:
        Total cost including tax
    """
    total = sum(item['price'] for item in items)
    tax_amount = total * tax_rate
    return total + tax_amount
```

### Control Flow and Error Handling
```alg-python
def process_user_input(input_data: str | None) -> str:
    """Process user input with validation and error handling.
    
    Args:
        input_data: User input string or None
        
    Returns:
        Processed result or error message
        
    Raises:
        ValueError: When input format is invalid
    """
    if not input_data:
        return "Empty input error"
    
    if not is_valid_input(input_data):
        raise ValueError("Invalid input format")
    
    try:
        result = process_input(input_data)
        return f"Success: {result}"
    except Exception as e:
        return f"Processing error: {e}"

def is_valid_input(data: str) -> bool:
    """Validate input data format."""
    return data.strip() and len(data) > 0
```

### Iterative Algorithms
```alg-python
from typing import Iterator

def find_max_value(array: list[int | float]) -> int | float:
    """Find maximum value in array using iterative approach.
    
    Args:
        array: List of numeric values
        
    Returns:
        Maximum value in array
        
    Raises:
        ValueError: When array is empty
    """
    if not array:
        raise ValueError("Cannot find max of empty array")
    
    max_val = array[0]
    for value in array[1:]:
        if value > max_val:
            max_val = value
    
    return max_val

def fibonacci_generator(n: int) -> Iterator[int]:
    """Generate Fibonacci sequence up to n terms.
    
    Args:
        n: Number of Fibonacci terms to generate
        
    Yields:
        Next Fibonacci number in sequence
    """
    a, b = 0, 1
    for _ in range(n):
        yield a
        a, b = b, a + b
```

### Data Structure Algorithms
```alg-python
from collections import defaultdict
from typing import Any, Dict, List, Set

class GraphAlgorithms:
    """Collection of graph algorithms."""
    
    @staticmethod
    def breadth_first_search(
        graph: Dict[Any, List[Any]], 
        start: Any, 
        target: Any
    ) -> List[Any] | None:
        """BFS pathfinding algorithm.
        
        Args:
            graph: Adjacency list representation
            start: Starting node
            target: Target node
            
        Returns:
            Path from start to target, or None if no path exists
        """
        from collections import deque
        
        if start == target:
            return [start]
        
        queue = deque([(start, [start])])
        visited: Set[Any] = {start}
        
        while queue:
            current, path = queue.popleft()
            
            for neighbor in graph.get(current, []):
                if neighbor == target:
                    return path + [neighbor]
                
                if neighbor not in visited:
                    visited.add(neighbor)
                    queue.append((neighbor, path + [neighbor]))
        
        return None
    
    @staticmethod
    def dijkstra_shortest_path(
        graph: Dict[Any, Dict[Any, int]], 
        start: Any
    ) -> Dict[Any, int]:
        """Dijkstra's shortest path algorithm.
        
        Args:
            graph: Weighted adjacency list
            start: Starting node
            
        Returns:
            Dictionary mapping nodes to shortest distances
        """
        import heapq
        
        distances = defaultdict(lambda: float('inf'))
        distances[start] = 0
        heap = [(0, start)]
        visited: Set[Any] = set()
        
        while heap:
            current_dist, current = heapq.heappop(heap)
            
            if current in visited:
                continue
                
            visited.add(current)
            
            for neighbor, weight in graph.get(current, {}).items():
                distance = current_dist + weight
                
                if distance < distances[neighbor]:
                    distances[neighbor] = distance
                    heapq.heappush(heap, (distance, neighbor))
        
        return dict(distances)
```

### Recursive Algorithms
```alg-python
def merge_sort(arr: list[int]) -> list[int]:
    """Merge sort implementation with divide-and-conquer.
    
    Args:
        arr: List of integers to sort
        
    Returns:
        Sorted list
    """
    if len(arr) <= 1:
        return arr
    
    mid = len(arr) // 2
    left = merge_sort(arr[:mid])
    right = merge_sort(arr[mid:])
    
    return merge(left, right)

def merge(left: list[int], right: list[int]) -> list[int]:
    """Merge two sorted lists."""
    result = []
    i = j = 0
    
    while i < len(left) and j < len(right):
        if left[i] <= right[j]:
            result.append(left[i])
            i += 1
        else:
            result.append(right[j])
            j += 1
    
    result.extend(left[i:])
    result.extend(right[j:])
    return result
```

## Python-Specific Conventions

### Type Annotations
- Use modern type hints: `list[int]`, `dict[str, Any]`
- Specify return types and parameter types
- Use `| None` for optional returns
- Import from `typing` for complex types

### Documentation
- Use docstrings with Google or NumPy style
- Include `Args:`, `Returns:`, `Raises:` sections
- Provide usage examples when helpful

### Error Handling
- Use specific exception types
- Provide meaningful error messages
- Handle edge cases explicitly

### Code Style
- Follow PEP 8 conventions
- Use descriptive variable names
- Prefer comprehensions for simple operations
- Use appropriate data structures (defaultdict, deque, etc.)

## Parameters
- **Type Hints**: Specify input/output types for clarity
- **Docstrings**: Required for algorithm documentation
- **Error Handling**: Include appropriate exception handling
- **Performance**: Consider time/space complexity implications

* * *

# npl/instructing/annotation.md
---
# Iterative Refinement Patterns
Annotation-based techniques for progressive improvement of code, designs, and solutions through structured feedback and modification cycles.

## Syntax
```syntax
```annotation
original: [existing content]
issues: [identified problems]
refinement: [improved version]
```

```annotation-cycle
iteration: <number>
focus: <area of improvement>
changes: [specific modifications]
validation: [verification method]
```
```

## Purpose
Annotation patterns enable systematic improvement of outputs through iterative cycles, allowing for progressive refinement based on feedback, testing, and evolving requirements.

## Usage
Use annotation patterns for:
- Code review and improvement cycles
- UX design iteration processes
- Progressive solution refinement
- Quality assurance workflows

## Annotation Types

### Basic Refinement
```example
```annotation
original: |
  function calculate(a, b) {
    return a + b;
  }
issues:
  - No input validation
  - Limited to addition only
refinement: |
  function calculate(a, b, operation = 'add') {
    if (typeof a !== 'number' || typeof b !== 'number') {
      throw new Error('Invalid input: numbers required');
    }
    switch(operation) {
      case 'add': return a + b;
      case 'subtract': return a - b;
      case 'multiply': return a * b;
      case 'divide': return b !== 0 ? a / b : null;
      default: throw new Error('Unsupported operation');
    }
  }
```
```

### Progressive Design Iteration
```example
```annotation-cycle
iteration: 1
focus: User interface layout
changes:
  - Moved navigation to sidebar
  - Increased button sizes for mobile
  - Added color contrast improvements
validation: Accessibility audit + user testing
```
```

### Multi-Stage Refinement
```example
```annotation
stage: analysis
findings:
  - Performance bottleneck in data processing
  - Memory usage could be optimized
  - Error handling needs improvement

stage: implementation
changes:
  - Implemented data streaming instead of batch loading
  - Added memory pool for object reuse
  - Enhanced error recovery mechanisms

stage: validation
metrics:
  - 40% performance improvement
  - 25% reduction in memory usage
  - Zero unhandled exceptions in testing
```
```

## Refinement Patterns

### Code Enhancement Cycle
1. **Identify**: Mark areas needing improvement
2. **Analyze**: Document specific issues or limitations
3. **Refine**: Implement enhanced version
4. **Validate**: Test and verify improvements
5. **Iterate**: Repeat cycle if further refinement needed

### Design Evolution Pattern
```example
```annotation
version: 1.0
design: Initial wireframe with basic functionality
feedback: Users find navigation confusing

version: 2.0  
design: Reorganized navigation with clear hierarchy
feedback: Better, but mobile experience needs work

version: 3.0
design: Responsive design with mobile-first approach
feedback: Excellent usability across devices
```
```

### Quality Improvement Framework
```example
```annotation-cycle
cycle: security-review
focus: Input validation and sanitization
issues:
  - SQL injection vulnerabilities
  - Cross-site scripting risks
  - Insufficient authorization checks
remediation:
  - Parameterized queries implemented
  - Input sanitization added
  - Role-based access control enhanced
verification: Penetration testing passed
```
```

## Advanced Techniques

### Collaborative Refinement
```example
```annotation
author: developer-a
original: [initial implementation]
reviewer: developer-b
suggestions: [code review feedback]
author: developer-a
refinement: [updated implementation]
reviewer: developer-b
approval: Changes address all concerns
```
```

### Metric-Driven Improvement
```example
```annotation
baseline_metrics:
  - Load time: 3.2s
  - Error rate: 2.1%
  - User satisfaction: 3.2/5
target_improvements:
  - Load time: <2.0s
  - Error rate: <1.0%
  - User satisfaction: >4.0/5
implementation: [optimization strategies]
results:
  - Load time: 1.8s ✓
  - Error rate: 0.7% ✓ 
  - User satisfaction: 4.3/5 ✓
```
```

## Integration with Other Patterns

### With Chain of Thought
Use annotation to refine reasoning processes:
```example
```annotation
thought_process: [initial reasoning]
reflection: [identified logical gaps]
refined_reasoning: [improved analysis]
conclusion: [updated solution]
```
```

### With Template Systems
Apply refinement to template designs:
```example
```annotation
template_version: 1
issues: [layout problems]
template_version: 2  
improvements: [enhanced structure]
```
```

## See Also
- `./.claude/npl/pumps/npl-reflection.md` - Self-assessment patterns
- `./.claude/npl/pumps/npl-critique.md` - Critical analysis techniques
- `./.claude/npl/instructing/second-order.md` - Higher-order improvement patterns
* * *

# npl/instructing/formal-proof.md
---
# Formal Proof Structures
Structured frameworks for constructing rigorous mathematical and logical proofs using systematic reasoning methods and formal inference rules.

## Syntax
```syntax
```proof
Given: [premises]
To Prove: [conclusion]
Proof:
  1. [step] - [justification]
  2. [step] - [justification]
  ...
  n. [conclusion] - [final justification]
```

```natural-deduction
[premises]
─────────── [rule name]
[conclusion]
```
```

## Purpose
Formal proof structures provide systematic frameworks for constructing valid logical arguments, ensuring mathematical rigor, and establishing the truth of statements through step-by-step reasoning.

## Usage
Use formal proofs for:
- Mathematical theorem verification
- Logical argument validation  
- Algorithm correctness proofs
- System property verification
- Scientific hypothesis testing

## Proof Methods

### Direct Proof
```example
```proof
Theorem: If n is even, then n² is even.
Given: n is even (n = 2k for some integer k)
To Prove: n² is even

Proof:
1. n = 2k - Given (n is even)
2. n² = (2k)² - Substitution
3. n² = 4k² - Algebraic manipulation  
4. n² = 2(2k²) - Factoring
5. Since 2k² is an integer, n² = 2m where m = 2k² - Definition
6. Therefore, n² is even - Definition of even number ∎
```
```

### Proof by Contradiction
```example
```proof
Theorem: √2 is irrational
Given: √2 exists as a real number
To Prove: √2 cannot be expressed as p/q where p,q are integers with gcd(p,q) = 1

Proof by Contradiction:
1. Assume √2 is rational - Assumption for contradiction
2. Then √2 = p/q where gcd(p,q) = 1 - Definition of rational
3. 2 = p²/q² - Squaring both sides
4. 2q² = p² - Algebraic manipulation
5. p² is even - Since 2q² = p²
6. p is even - If p² even, then p even
7. p = 2r for some integer r - Definition of even
8. 2q² = (2r)² = 4r² - Substitution
9. q² = 2r² - Dividing by 2
10. q² is even, therefore q is even - Same logic as steps 5-6
11. Both p and q are even - From steps 6 and 10
12. gcd(p,q) ≥ 2 - Contradiction with assumption gcd(p,q) = 1
13. Therefore, √2 is irrational ∎
```
```

### Mathematical Induction
```example
```proof
Theorem: For all n ≥ 1, 1 + 2 + 3 + ... + n = n(n+1)/2
To Prove: ∀n ∈ ℕ₊, ∑ᵢ₌₁ⁿ i = n(n+1)/2

Proof by Induction:
Base Case (n = 1):
1. LHS = 1 - Direct calculation
2. RHS = 1(1+1)/2 = 1 - Formula evaluation  
3. LHS = RHS ✓ - Base case verified

Inductive Step:
Assume: ∑ᵢ₌₁ᵏ i = k(k+1)/2 for some k ≥ 1
To Prove: ∑ᵢ₌₁ᵏ⁺¹ i = (k+1)(k+2)/2

4. ∑ᵢ₌₁ᵏ⁺¹ i = ∑ᵢ₌₁ᵏ i + (k+1) - Expanding sum
5. = k(k+1)/2 + (k+1) - Inductive hypothesis
6. = (k+1)[k/2 + 1] - Factoring
7. = (k+1)(k+2)/2 - Simplification
8. Therefore, P(k+1) is true - Inductive step complete

Conclusion: By mathematical induction, the formula holds for all n ≥ 1 ∎
```
```

## Natural Deduction Rules

### Basic Inference Rules
```example
```natural-deduction
Modus Ponens:
P → Q    P
─────────
    Q

Modus Tollens:  
P → Q    ¬Q
─────────
    ¬P

Hypothetical Syllogism:
P → Q    Q → R  
─────────────
     P → R
```
```

### Quantifier Rules
```example
```natural-deduction
Universal Instantiation:
∀x P(x)
─────────
 P(a)

Universal Generalization:
P(a) [where a is arbitrary]
──────────────────────
      ∀x P(x)

Existential Instantiation:
∃x P(x)
─────────────────
P(c) [for new constant c]

Existential Generalization:
P(a)
─────────
∃x P(x)
```
```

## Advanced Proof Techniques

### Proof by Cases
```example
```proof
Theorem: For any integer n, n² - n is even
To Prove: ∀n ∈ ℤ, 2 | (n² - n)

Proof by Cases:
Case 1: n is even
1. n = 2k for some integer k - Assumption
2. n² - n = (2k)² - 2k = 4k² - 2k = 2(2k² - k) - Algebraic manipulation
3. Since (2k² - k) is an integer, n² - n is even ✓

Case 2: n is odd  
1. n = 2k + 1 for some integer k - Assumption
2. n² - n = (2k + 1)² - (2k + 1) - Substitution
3. = 4k² + 4k + 1 - 2k - 1 - Expansion
4. = 4k² + 2k = 2(2k² + k) - Simplification
5. Since (2k² + k) is an integer, n² - n is even ✓

Conclusion: In both cases, n² - n is even ∎
```
```

### Constructive Proof
```example
```proof
Theorem: For any two rational numbers r and s, there exists a rational number between them
Given: r, s ∈ ℚ with r < s
To Prove: ∃t ∈ ℚ such that r < t < s

Constructive Proof:
1. Let t = (r + s)/2 - Construction
2. r = r/2 + r/2 < r/2 + s/2 = (r + s)/2 = t - Since r < s
3. t = (r + s)/2 < s/2 + s/2 = s - Since r < s  
4. Since r, s ∈ ℚ, we have t = (r + s)/2 ∈ ℚ - Closure under arithmetic
5. Therefore, t is rational and r < t < s ∎
```
```

## Proof Verification Patterns

### Soundness Check
```example
```verification
Proof Soundness Criteria:
1. ∀step(ValidInference(step)) - Each step follows valid inference rules
2. ∀premise(Justified(premise)) - All premises are established  
3. LogicalFlow(proof) - Steps form coherent logical progression
4. Complete(proof) - No logical gaps between premises and conclusion
```
```

### Completeness Analysis
```example
```verification
Completeness Assessment:
1. AllCasesConsidered(proof) - Exhaustive case analysis when needed
2. NoAssumptionsUnstated(proof) - All assumptions explicitly stated
3. ConclusionFollows(premises, conclusion) - Conclusion logically follows
4. NoCircularReasoning(proof) - No circular dependencies in logic
```
```

## Integration with Other Systems

### Algorithm Correctness Proofs
```example
```algorithm-proof
Algorithm: BinarySearch(array A, target x)
Precondition: A is sorted in ascending order
Postcondition: Returns index i such that A[i] = x, or -1 if x ∉ A

Correctness Proof:
Loop Invariant: A[low..high] contains x if x ∈ A
1. Initialization: Invariant true when low = 0, high = length(A) - 1
2. Maintenance: Each iteration preserves invariant while reducing search space
3. Termination: Loop terminates when low > high or element found
4. Correctness: Upon termination, element found or proven absent ∎
```
```

### System Property Verification
```example
```system-proof  
Property: Mutual Exclusion in Critical Section
System: Two processes P₁, P₂ accessing shared resource
To Prove: ¬(InCritical(P₁) ∧ InCritical(P₂))

State Space Analysis:
1. States: {Idle, Waiting, Critical} for each process
2. Transitions: Governed by synchronization protocol
3. Invariant: At most one process in Critical state
4. Proof by state space enumeration and transition analysis ∎
```
```

## Proof Documentation Standards

### Structured Format
```example
```proof-template
Theorem: [Statement]
Context: [Background assumptions]
Significance: [Why this matters]

Proof Strategy: [High-level approach]
Key Insights: [Important observations]

Detailed Proof:
[Step-by-step argumentation]

Verification: [Soundness checks]
Extensions: [Related results or generalizations] ∎
```
```

## See Also
- `./.claude/npl/instructing/symbolic-logic.md` - Symbolic notation systems
- `./.claude/npl/instructing/second-order.md` - Higher-order reasoning patterns  
- `./.claude/npl/instructing/alg-speak.md` - Algorithm specification and analysis
- `./.claude/npl/pumps/npl-cot.md` - Chain of thought reasoning structures
* * *

# npl/instructing/handlebars.md
---
# Handlebars Template Control Flow
Template-like control structures for conditional logic, loops, and dynamic content generation.

## Syntax
```syntax
{{directive}}content{{/directive}}
{{directive|qualifier}}content{{/directive}}
```

## Purpose
Handlebars syntax provides structured control flow for templates, enabling conditional rendering, iteration over collections, and dynamic content generation based on context or data.

## Usage
Use handlebars when you need to:
- Generate repetitive content with variations
- Apply conditional logic to output sections
- Iterate over collections or datasets
- Create reusable template patterns

## Control Structures

### Conditional Logic
```example
{{if user.role == 'administrator'}}
Admin Panel Content
{{else}}
User Dashboard Content
{{/if}}
```

### Unless Blocks
```example
{{unless check|additional instructions}}
Content only shown when check is not met
{{/unless}}
```

### Iteration
```example
{{foreach breeds as breed}}
## {{breed.name}}
Description: {{breed.description}}
{{/foreach}}
```

### Nested Control Flow
```example
{{foreach business.executives as executive}}
- Name: {{executive.name}}
- Role: {{executive.role}}
{{if executive.bio}}
- Bio: {{executive.bio}}
{{/if}}
{{/foreach}}
```

## Advanced Patterns

### Qualified Directives
Use the pipe qualifier to add instructions or conditions:
```example
{{foreach|from 5 random cat breeds as breed}}
## {{breed.name}}
{{breed.description|2-3 sentences}}
{{/foreach}}
```

### Complex Template Integration
```example
{{foreach business.board_advisors as advisor}}
⟪⇆: user-template | with the data of each board advisor⟫
{{/foreach}}
```

## Parameters
- `condition`: Boolean expression for if/unless blocks
- `collection`: Data set for iteration in foreach blocks
- `variable`: Iterator variable name in foreach blocks
- `qualifier`: Additional instructions using pipe syntax

## Error Handling
If handlebars syntax causes formatting issues, ensure:
- Proper opening and closing tags
- Correct nesting of control structures
- Valid variable references in expressions

* * *

# npl/instructing/second-order.md
---
# Higher-Order Logic Patterns
Advanced reasoning structures that operate on logic, functions, and reasoning processes themselves, enabling meta-level analysis and abstract pattern manipulation.

## Syntax
```syntax
∀P(P(x) → Q(x)) - Universal quantification over predicates
∃F(∀x(F(x) ≡ P(x))) - Existential quantification over functions
λx.φ(x) - Lambda abstraction for higher-order functions
```

## Purpose
Higher-order logic patterns enable reasoning about reasoning itself, manipulation of logical structures as objects, and creation of abstract frameworks that can be applied across multiple domains.

## Usage
Use higher-order patterns for:
- Meta-reasoning about problem-solving approaches
- Creating reusable logical frameworks
- Analyzing patterns in reasoning processes
- Building adaptive problem-solving systems

## Core Concepts

### Second-Order Quantification
Quantifying over predicates and relations:
```example
```logic
∀P∃x(P(x)) → ∃x∀P(P(x))
// "If every property has an instance, then there exists an object with every property"

∀R(Reflexive(R) → ∃x(R(x,x)))
// "Every reflexive relation has at least one self-related element"
```
```

### Function Abstraction
Creating and manipulating functions as first-class objects:
```example
```logic
λf.λx.f(f(x)) - Function composition operator
λP.λQ.λx.(P(x) ∧ Q(x)) - Predicate conjunction combinator
λR.λx.λy.(R(y,x)) - Relation reversal operator
```
```

### Meta-Logical Reasoning
Reasoning about logical systems themselves:
```example
```meta-logic
Given logical system S:
- Consistency(S) ≔ ¬∃φ(Provable(S,φ) ∧ Provable(S,¬φ))
- Completeness(S) ≔ ∀φ(True(φ) → Provable(S,φ))
- Soundness(S) ≔ ∀φ(Provable(S,φ) → True(φ))
```
```

## Pattern Applications

### Problem-Solving Meta-Strategies
```example
```second-order
Strategy: AdaptiveApproach
Input: Problem P, Strategy Set S
Process:
1. ∀s ∈ S: Evaluate(Applicability(s,P))
2. Select s* where Utility(s*,P) = max{Utility(s,P) | s ∈ S}
3. Apply(s*,P) → Result R
4. If Satisfactory(R): Return R
5. Else: S' = S ∪ {Modify(s*,P,R)} and recurse

Meta-Pattern:
∀P∀S(AdaptiveApproach(P,S) → ImprovedStrategy(P,S))
```
```

### Logical Framework Construction
```example
```framework
Framework: GenericProofSystem
Parameters: 
- Axioms: ∀A(ValidAxiom(A))
- Rules: ∀R(ValidInferenceRule(R))
- Domain: ∀D(ValidDomain(D))

Construction:
λA.λR.λD.ProofSystem(A,R,D) where
- Sound(ProofSystem(A,R,D))
- Complete(ProofSystem(A,R,D)) when possible
- Decidable(ProofSystem(A,R,D)) when feasible
```
```

### Pattern Recognition in Reasoning
```example
```pattern-analysis
ReasoningPattern: ChainOfThought
Structure: ∃f(∀step_i(Depends(step_{i+1}, f(step_i))))
Properties:
- Monotonic(f) - Each step builds on previous
- Coherent(chain) - Steps form logical sequence  
- Terminating(chain) - Reaches definitive conclusion

Meta-Analysis:
∀problem(Applicable(ChainOfThought, problem) ↔ 
         Decomposable(problem) ∧ Sequential(solution))
```
```

## Advanced Techniques

### Type Theory Integration
```example
```type-theory
Higher-Order Types:
- (α → β) → γ - Functions that take functions as input
- ∀α.(α → α) - Polymorphic identity functions
- ∃τ.(τ → Bool) - Existential types for predicates

Dependent Types:
- Π(x:A).B(x) - Product type depending on value x
- Σ(x:A).B(x) - Sum type depending on value x
```
```

### Category Theory Applications
```example
```category-theory
Category of Reasoning Patterns:
Objects: ReasoningStrategy
Morphisms: StrategyTransformation
Composition: (g ∘ f)(strategy) = g(f(strategy))

Functors:
- Domain Transfer: F(strategy_dom1) → strategy_dom2
- Abstraction Level: G(concrete) → abstract
```
```

### Recursive Meta-Reasoning
```example
```recursive-meta
Level 0: Basic logical reasoning
Level 1: Reasoning about Level 0 strategies  
Level 2: Reasoning about Level 1 meta-strategies
Level n: Reasoning about Level n-1 patterns

Termination Condition:
∃k(∀n>k(MetaLevel(n) ≡ MetaLevel(k)))
// Meta-reasoning converges to fixed point
```
```

## Integration Patterns

### With Chain of Thought
```example
```integration
Enhanced CoT with Second-Order Reflection:
1. Apply standard chain-of-thought
2. Meta-analyze reasoning quality: ∀step(Valid(step) ∧ Necessary(step))
3. Identify improvement patterns: ∃f(Better(f(reasoning)))
4. Apply higher-order corrections
5. Validate meta-reasoning consistency
```
```

### With Formal Proofs
```example
```proof-enhancement
Standard Proof + Higher-Order Validation:
Proof: P → Q
Meta-Proof: ∀R(Similar(P,R) → ∃S(Proof(R→S) ∧ Similar(Q,S)))
// Proof method generalizes to similar problems
```
```

## Practical Applications

### Adaptive Problem Solving
- Self-modifying solution strategies
- Dynamic approach selection based on problem characteristics
- Learning from meta-patterns in successful solutions

### Knowledge Representation
- Abstract frameworks that capture reasoning patterns
- Reusable logical structures across domains
- Meta-knowledge about knowledge representation itself

## See Also
- `./.claude/npl/instructing/formal-proof.md` - Formal proof structures
- `./.claude/npl/instructing/symbolic-logic.md` - Symbolic representations
- `./.claude/npl/pumps/npl-cot.md` - Chain of thought reasoning
- `./.claude/npl/pumps/npl-reflection.md` - Meta-cognitive patterns
* * *

# npl/instructing/symbolic-logic.md
---
# Symbolic Logic Representations
Formal symbolic notation systems for expressing logical relationships, mathematical operations, and reasoning structures using standardized mathematical symbols.

## Syntax
```syntax
∀x P(x) - Universal quantification
∃x P(x) - Existential quantification  
P(x) → Q(x) - Logical implication
P(x) ↔ Q(x) - Logical equivalence
```

## Purpose
Symbolic logic provides precise, unambiguous notation for expressing logical relationships, mathematical concepts, and reasoning patterns that can be manipulated and analyzed systematically.

## Usage
Use symbolic logic for:
- Formal specification of logical relationships  
- Mathematical proof construction
- Precise expression of conditional logic
- Set theory and mathematical operations
- Algorithmic reasoning patterns

## Core Symbols

### Logical Connectives
```example
∧ - Logical AND (conjunction)
∨ - Logical OR (disjunction)  
¬ - Logical NOT (negation)
→ - Implication (if...then)
↔ - Biconditional (if and only if)
⊕ - Exclusive OR (XOR)
```

### Quantifiers
```example
∀ - Universal quantifier ("for all")
∃ - Existential quantifier ("there exists")
∃! - Unique existence ("there exists exactly one")
∄ - Non-existence ("there does not exist")
```

### Set Operations  
```example
∪ - Union
∩ - Intersection
∖ - Set difference
⊆ - Subset
⊂ - Proper subset
∈ - Element of
∉ - Not element of
∅ - Empty set
```

### Mathematical Relations
```example
= - Equality
≠ - Inequality  
< - Less than
≤ - Less than or equal
> - Greater than
≥ - Greater than or equal
≡ - Equivalence
≈ - Approximately equal
```

## Application Patterns

### Propositional Logic
```example
```symbolic
Given propositions P, Q, R:
- Modus Ponens: (P → Q) ∧ P ⊢ Q
- Modus Tollens: (P → Q) ∧ ¬Q ⊢ ¬P
- Hypothetical Syllogism: (P → Q) ∧ (Q → R) ⊢ (P → R)
- Disjunctive Syllogism: (P ∨ Q) ∧ ¬P ⊢ Q
```
```

### Predicate Logic
```example
```symbolic
Domain: Natural numbers ℕ
Predicates:
- Even(x) ≔ ∃k ∈ ℕ(x = 2k)
- Prime(x) ≔ x > 1 ∧ ∀y((y|x) → (y = 1 ∨ y = x))

Statements:
- ∀x ∈ ℕ(Even(x) ∨ Odd(x))
- ∃x ∈ ℕ(Prime(x) ∧ Even(x)) // True: x = 2
- ∀x ∈ ℕ(Prime(x) ∧ x > 2 → Odd(x))
```
```

### Set Theory Applications
```example
```symbolic
Set Relationships:
- Subset: A ⊆ B ↔ ∀x(x ∈ A → x ∈ B)
- Equal sets: A = B ↔ (A ⊆ B ∧ B ⊆ A)
- Disjoint: A ∩ B = ∅
- Complement: A^c = {x : x ∉ A}

Set Operations:
- Union: A ∪ B = {x : x ∈ A ∨ x ∈ B}
- Intersection: A ∩ B = {x : x ∈ A ∧ x ∈ B}
- Difference: A ∖ B = {x : x ∈ A ∧ x ∉ B}
```
```

## Advanced Symbolic Patterns

### Function Notation
```example
```symbolic
Function Definition:
f: A → B (f maps A to B)
f(x) = y where x ∈ A, y ∈ B

Function Properties:
- Injective: ∀x₁,x₂ ∈ A(f(x₁) = f(x₂) → x₁ = x₂)
- Surjective: ∀y ∈ B∃x ∈ A(f(x) = y)  
- Bijective: Injective ∧ Surjective
```
```

### Algorithmic Logic
```example
```symbolic
Conditional Logic in Algorithms:
if (condition) { action } else { alternative }
≡ (condition → action) ∧ (¬condition → alternative)

Loop Invariants:
∀i(0 ≤ i ≤ n → Invariant(i))
where Invariant(i) specifies what remains true during iteration
```
```

### Mathematical Proofs
```example
```symbolic
Proof by Contradiction:
To prove P, assume ¬P and derive contradiction:
¬P ⊢ (Q ∧ ¬Q) ⊢ ⊥
Therefore: ⊢ P

Proof by Induction:
Base case: P(0)
Inductive step: ∀k(P(k) → P(k+1))
Conclusion: ∀n ∈ ℕ(P(n))
```
```

## Complex Expressions

### Modal Logic
```example
```symbolic
Necessity and Possibility:
□P - "P is necessarily true"
◇P - "P is possibly true"
□P → P - "What is necessary is true"
P → ◇P - "What is true is possible"
□(P → Q) → (□P → □Q) - Kripke's K axiom
```
```

### Temporal Logic
```example
```symbolic
Temporal Operators:
◯P - "P holds in the next state"
□P - "P always holds" (globally)
◇P - "P eventually holds" (finally)
P U Q - "P holds until Q holds"

Properties:
◇□P - "P eventually always holds"
□◇P - "P holds infinitely often"
```
```

## Integration with Other Systems

### With Algorithm Specification
```example
```symbolic
Algorithm Correctness:
{Precondition} Algorithm {Postcondition}
∀x(Precondition(x) → Postcondition(Algorithm(x)))

Complexity Analysis:
∃c,n₀∀n≥n₀(T(n) ≤ c·f(n))
// Algorithm runtime T(n) is O(f(n))
```
```

### With Formal Proofs
```example
```symbolic
Proof Structure:
Premises: P₁, P₂, ..., Pₙ
Inference Rules: R₁, R₂, ..., Rₘ  
Conclusion: Q

Validity: (P₁ ∧ P₂ ∧ ... ∧ Pₙ) → Q
```
```

## Practical Applications

### Specification Languages
Use symbolic logic to specify:
- System requirements and constraints
- API contracts and interfaces  
- Database integrity constraints
- Security policies and access controls

### Automated Reasoning
Enable automated systems to:
- Verify logical consistency
- Generate proofs automatically
- Check satisfiability of constraints
- Optimize logical expressions

## Common Patterns in NPL Context

### Conditional Content Generation
```example
if (user.role == 'administrator') { Show admin panel } else { Show user dashboard }
≡ (Administrator(user) → AdminPanel) ∧ (¬Administrator(user) → UserDashboard)
```

### Set-Based Operations
```example
Customer segmentation:
sports_enthusiasts ∩ health_focused
≡ {x : SportsInterest(x) ∧ HealthFocus(x)}
```

* * *
