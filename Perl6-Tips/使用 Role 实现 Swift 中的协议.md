title:  使用 Role 实现 Swift 中的协议

date: 2016-01-12

tags: Perl6

categories: Perl 6

---

<blockquote class='blockquote-center'> 路灯下, 你的身影, 看得见却看不清！</blockquote>

Protocol 在 Swift 中是一组方法和属性的集合, 可用于代码复用。 Perl 6 中有与之类似的结构, 叫做 `Role`, 下面转换一个 Swift 的 Protocol 为 Perl 6 的 Role, 把部门人员的相关信息打印为一个表格:

## Protocol in Swift

``` perl
import UIKit

func padding(amount: Int) -> String {
    var paddingString = ""
    for _ in 0..<amount {
        paddingString += " "
    }
    return paddingString
}

// 协议

protocol TabularDataSource {
    var numberOfRows: Int    { get }
    var numberOfColumns: Int { get }
    
    func labelForRow(row: Int) -> String        // 行标签
    func labelForColumn(column: Int) -> String  // 列标签
    
    func itemForRow(row: Int, column: Int) -> Int // 表格中的单元格
}



struct Person {
    let name: String
    let age: Int
    let yearsOfExperience: Int
}

// 让 **Department** 遵守 **TabularDataSource**协议
struct Department: TabularDataSource {
    let name: String
    var people = [Person]()
    
    init(name: String) {
        self.name = name
    }
    
    mutating func addPerson(person: Person) {
        people.append(person)
    }
    
    // 实现协议中声明的属性和方法
    var numberOfRows: Int {
        return people.count
    }
    
    var numberOfColumns: Int {
        return 2
    }
    
    func labelForRow(row: Int) -> String {
        return people[row].name
    }
    
    func labelForColumn(column: Int) -> String {
        switch column {
            case 0: return "Age"
            case 1: return "Years of Experence"
            default: fatalError("Invalid column!")
        }
    }
    
    func itemForRow(row: Int, column: Int) -> Int {
         let person = people[row] // 指定的行
         switch column {
             case 0: return person.age
             case 1: return person.yearsOfExperience
             default:fatalError("Invalid column!")
        }
    }
}

var deparment = Department(name: "Engineering")
deparment.addPerson(Person(name: "Joe", age: 30, yearsOfExperience: 6))
deparment.addPerson(Person(name: "Karen", age: 40, yearsOfExperience: 18))
deparment.addPerson(Person(name: "Fred", age: 50, yearsOfExperience: 20))

// 传入一个数据源
func printTable(dataSource: TabularDataSource) {
    let rowLabels = (0 ..< dataSource.numberOfRows).map { dataSource.labelForRow($0) }
    let columnLabels = (0 ..< dataSource.numberOfColumns).map { dataSource.labelForColumn($0) }
    
    // 创建一个数组存储每个行标签的宽度
    let rowLabelWidths = rowLabels.map { $0.characters.count }
    
    // 限定行标签的最大长度
    guard let maxRowLabelWidth = rowLabelWidths.maxElement() else {
        return
    }
    
    // 创建第一行, 包含列标题
    var firstRow = padding(maxRowLabelWidth) + " |"
    
    // 跟踪每列的宽度
    var columnWidths = [Int]()
    
    for columnLabel in columnLabels {
        let columnHeader = " \(columnLabel) |"
        firstRow += columnHeader
        columnWidths.append(columnHeader.characters.count)
    }
    print(firstRow)
    
    for i in 0 ..< dataSource.numberOfRows {
        let paddingAmount = maxRowLabelWidth - rowLabelWidths[i]
        var out = rowLabels[i] + padding(paddingAmount) + " |"
        
        for j in 0 ..< dataSource.numberOfColumns {
            let item = dataSource.itemForRow(i, column: j)
            let itemString = " \(item) |"
            let paddingAmount = columnWidths[j] - itemString.characters.count
            out += padding(paddingAmount) + itemString
        }
        print(out)
    }
}

printTable(deparment)

```

其中的计算属性在 Perl 6 中可以使用重写属性的方法来完成。

### Role in Perl 6

``` perl
use v6;

sub padding(Int $amount) {
    my $paddingString = "";
    $paddingString ~= " " for  0 ..^ $amount;
    return $paddingString;
}

# 声明一个接口, 只定义了方法和属性, 没有做实现
role TabularDataSource {
    has $.numberOfRows is rw;
    has $.numberOfColumns is rw;

    method labelForRow(Int $row)             { ... }
    method labelForColumn(Int $column)       { ... }
    method itemForRow(Int $row, Int $column) { ... }
}

class Person {
    has Str $.name;
    has Int $.age;
    has Int $.yearsOfExperience;
}

class Department does TabularDataSource {
    has $.name;
    has @.people;

    method new(Str $name) {
        self.bless(name => $name);
    }
    # 实现接口中的方法

    # 重写方法 has $.numberOfRows 其实是 has $!numberOfRows 加上 method numberOfRows() { ... } 方法。
    method numberOfRows() {
        return @!people.elems;
    }

    method numberOfColumns() {
        return 2;
    }

    method addPerson(Person $person) is rw {
        @!people.append($person);
    }
    # 如果类遵守了某个 role 但是未实现其中的方法, 则会报错如下:
    # Method 'labelForRow' must be implemented by Department because it is required by a role
    method labelForRow(Int $row) {
        return @!people[$row].name;
    }

    method labelForColumn(Int $column) {
        given $column {
            when 0  { return "Age" }
            when 1  { return "Years of Experence" }
            default { die("Invalid column!")}
        }
    }

    method itemForRow(Int $row, Int $column) {
        my $person = @!people[$row];
        given $column {
            when 0  { return $person.age               }
            when 1  { return $person.yearsOfExperience }
            default { die("Invalid column")            }
        }
    }
}

my $department = Department.new("Engineering");
$department.addPerson(Person.new(name => "Joe",   age => 30, yearsOfExperience => 6));
$department.addPerson(Person.new(name => "Karen", age => 40, yearsOfExperience => 18));
$department.addPerson(Person.new(name => "Fred",  age => 50, yearsOfExperience => 20));

sub printTable(TabularDataSource $dataSource) {
   my @rowLabels = (0 ..^ $dataSource.numberOfRows ).map: { $dataSource.labelForRow($_)};
   my @columnLabels = (0 ..^ $dataSource.numberOfColumns).map: {$dataSource.labelForColumn($_)};

   my @rowLabelWidths = @rowLabels.map: {$_.chars};
   my $maxRowLabelWidth = @rowLabelWidths.max // return;

   my $firstRow = padding($maxRowLabelWidth) ~ " |";
   my @columnWidths;

   for @columnLabels -> $columnLabel {
       my $columnHeader = " $columnLabel |";
       $firstRow ~= $columnHeader;
       @columnWidths.append($columnHeader.chars);
   }
   say($firstRow);

   for 0 ..^ $dataSource.numberOfRows -> $i {
        my $paddingAmount = $maxRowLabelWidth - @rowLabelWidths[$i];
        my $out = @rowLabels[$i] ~ padding($paddingAmount) ~ " |";

        for 0 ..^ $dataSource.numberOfColumns -> $j {
            my $item = $dataSource.itemForRow($i, $j);
            my $itemString = " $item |";
            my $paddingAmount = @columnWidths[$j] - $itemString.chars;
            $out ~= padding($paddingAmount) ~ $itemString;
        }
        say($out);
   }

}

printTable($department);

```

role 中的 `{ ... }` 是 yadayada操作符, 起占位作用, 表示方法会在别处实现。类中的方法同样也可以这样声明。

最后输出:

``` perl
      | Age | Years of Experence |
Joe   |  30 |                  6 |
Karen |  40 |                 18 |
Fred  |  50 |                 20 |
```

