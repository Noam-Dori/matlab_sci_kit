# MATLAB Scientific Kit
___
This package contains code aimed to help with 
graphing and obtaining linear regressions for data, 
and error estimation & calculation via the law of error propagation.

# Installation
The only thing you really need is the files inside the `src` folder. Download The files somehow 
(either via git or directly using the green button in this webpage),
and copy all files in the src to the top folder of your work.

# An Example
We will examine this script, that calculates the resistivity of some resistor.
```matlab
% measurements
voltage = [0.1, 0.2, 0.25, 0.3, 0.4, 0.5, 0.6];
current = [0.05, 0.11, 0.12, 0.15, 0.19, 0.26, 0.29];
% errors
voltage_err = 0.01;
current_err = 0.001;

V = Meas.from(voltage, voltage_err);
I = Meas.from(current, current_err);

titles.title = 'Voltage vs Direct Current';
titles.x_axis = 'Direct Current [A]';
titles.y_axis = 'Voltage [V]';
titles.fit = 'Regression';
titles.data = '$2\\Omega Resistor$';
VI_fit = Meas.fit(I, V, titles);

resistance = VI_fit.slope;
length = Meas(0.01, 0.0001);
width = Meas(0.005, 0.0001);

resistivity = resistance * width^2 / length
```

Let's examine what each part does
```matlab
% measurements
voltage = [0.1, 0.2, 0.25, 0.3, 0.4, 0.5, 0.6];
current = [0.05, 0.11, 0.12, 0.15, 0.19, 0.26, 0.29];
% errors
voltage_err = 0.01;
current_err = 0.001;
```
This is the raw data collected in the experiment, with error estimations.

```matlab
V = Meas.from(voltage, voltage_err);
I = Meas.from(current, current_err);
```
This converts the raw numbers we collected into the main object we are working 
with - measurements. Measurements have a value and uncertainty, or error.

- The value can be any real number
- the error can be any non-negative number, or -1.
  - Non-negative numbers indicate an error by that value. For example, in `V`, the first entry is 0.1±0.01.
  - `-1` is used to indicate completely theoretical values with no errors. For example, the speed of light.

```matlab
titles.title = 'Voltage vs Direct Current';
titles.x_axis = 'Direct Current [A]';
titles.y_axis = 'Voltage [V]';
titles.fit = 'Regression';
titles.data = '$2\\Omega Resistor$';
VI_fit = Meas.fit(I, V, titles);
```
This plots the linear relationship between `I` and `V`, i.e I as x and V as y, with error bars, and with the titles indicated 
by the `titles` object.

As a result we get 2 things:
- `VI_fit` stores the regression characteristics, like the slope, y-intercept, R^2, etc. 
  The slope and y intercept are measurements themselves.
- The function `Meas.fit` plots points (in a new figure) with x value I and y values V in a scatter plot along with the corresponding regression,
  and adds the error bars corresponding in the x,y direction with the sizes of the I error and V error respectively.

```matlab
resistance = VI_fit.slope;
```

This fetches the regression slope with its error

```matlab
length = Meas(0.01, 0.0001);
width = Meas(0.005, 0.0001);

resistivity = resistance * width^2 / length
```

This directly creates new measurements, one for the length, and one for the width.
Out of these measurements, we calculate the resistivity of the wire. Notice how we operated with the measurements
just like we would with regular numbers.

At the very end, we obtained a useful number with an error, which can be directly copied from the output into your document editor.

# Documentation

## Basic Measurement operations
To start working with this program, you need to make measurements, and know how to access its values.

### `Meas(value, err)`
create one scalar measurement. That is, one value with one error.
- `value`: this is the physical value this measurement holds. This can be any real value.
- `err`: this is the uncertainty, or error estimation of the value. This can be any non-negative number or -1, which represents
         theoretical values with no errors, like the speed of light.

### `Meas.from(values, errors)`
Creates a matrix of measurements using the matrix of values and the matrix of errors.
For example, if value is a n\*m matrix, the result would also be a n*m matrix.
- `values`: this is a matrix containing the physical values to be stored.
- `errors`: this is a matrix containing the errors of each respective value in the `value` matrix. Each dimension of this matrix
            can either match the corresponding dimension in `values` or simply be 1 to have it apply to all values in that dimension.

A big advantage of this method is that the matrices don't have to match in size. For example,
if you made a vector of measurements with the same error, any of the following will yield the same value:
```matlab
from_2_vectors =         Meas.from([1,2,3,4], [0.1,0.1,0.1,0.1]);
from_2_vectors_pain =    Meas.from([1,2,3,4], 0.1 * ones(4,2));
from_1_vectors_1_error = Meas.from([1,2,3,4], 0.1);
```

### `Meas#value`
get the value of the measurement. This works with matrices.

Examples:
```matlab
m = Meas(9.81,0.01);
a = Meas.from([1,2],0.1);

m_val = m.value % 9.81
a_val = a.value % 1    2
```

### `Meas#err`
get the error of the measurement. This works with matrices.

Examples:
```matlab
m = Meas(9.81,0.01);
a = Meas.from([1,2],0.1);

m_val = m.err % 0.01
a_val = a.err % 0.1    0.1
```

### `Meas#relative`
get the relative of the measurement, i.e err/value. This works with matrices.

Examples:
```matlab
m = Meas(9.81,0.01);
a = Meas.from([1,2],0.1);

m_val = m.relative % 0.00101
a_val = a.relative % 0.1    0.05
```

### `Meas.merge(measurements...)`
Takes multiples measurements and fuses them together, with respect to dimension 1, no matter the dimensions.

Each element in `measurements` can be:
- a measurement (or a matrix of measurements). These will be fused together along dimension 1 in the order they are given.
  On the other dimensions, any empty space will be filled with a blank space known by the program (for more details see `Meas.remove`).
- a formula (or a vector of formulas along dimension 1). This will calculate the measurements using the 
  previous entries in the argument list using the formula provided. See `Meas#apply` for more details.

Some examples:
```matlab
a = Meas.from([1,2],0.1);
b = Meas.from([3;4],0.2);
f = Meas.scalar(10); % a function that multiplies input by 10.
ab = Meas.merge(a,b) % "1±0.1" "2±0.1"
                     % "3±0.2" " "
                     % "4±0.2" " "
af = Meas.merge(a,f) % "1±0.1" "2±0.1"
                     % "10±1"  "20±1"
```

### `Meas.matchsizes(measL,measR)`
A utility function that extends `measL` and `measR` so that their dimensions match.

Example:
```matlab
a = Meas.from([1,2],0.1);
b = Meas.from([3;4],0.2);

[a,b] = Meas.matchsizes(a,b);
a % "1±0.1" "2±0.1"
  % "1±0.1" "2±0.1"
b % "3±0.2" "3±0.2"
  % "4±0.2" "4±0.2"
```

### `zeros(dims..., 'Meas')`
Creates a matrix with the sizes specified by the `dims` argument, each filled with the measurement 0±1.

### `Meas.remove(dims...)`
Creates a matrix with the sizes specified by the `dims` argument, each filled with the measurement 0±(-2).
"remove" measurements act as whitespace. They are completely ignored by the fit and plot tools, and can be used to group vectors that 
don't have the same dimensions together in the same matrix.

You don't really use this directly, but the program uses it for you.

### `Meas#string`
Displays the value and the error without exponent or rounding manipulation.

```matlab
m = Meas(0.03,0.0014);
m.string % 0.03±0.0014
```

### `Meas#disp`
An automatic function called when displaying Meas objects. This displays the measurement with the proper scientific form:
- both values are adjusted to the value's scientific notation (this is ignored with very small exponents)
- the error is rounded to the first significant digit, and the value is rounded to the digit matching 
  the error's first significant digit.

Example:
```matlab
Meas(0.03,0.0014) % (3±0.2)×10^-2
```

## Mathematical Operations
Like regular numbers, measurements can be operated on exactly the same way, with the mathematical operations we are
familiar with.

Consider we want to calculate `x^2+y^2`. To get that value we would simply write this exact expression with our x,y.
To do this with measurements, we do exactly the same:
```matlab
x = Meas(3,0.1);
y = Meas(4,0.1);

calculated = x^2 + y^2; % 25±0.3
```
This also calculated the error for the calculation automatically using the law of error propagation.
In addition, common mathematical functions are also supported, like `sin`.
Finally, you can mix together normal numbers and measurements. For instance, multiplying by a scalar would by

```matlab
x = Meas(3,0.1);
x_scaled = 10 * x; % 30±1
```

**Supported Operators/Functions:**
- Classic arithmetic: `+`,`-`,`*`,`/`,`^`
- Equality: `==`,`~=`
- Trigonometric functions: `sin`,`cos`,`tan`
- Logarithmic and Exponential: `exp`,`log`

### `Meas#apply(sym_func)`
Applies a generic function on the measurement.

`sym_func` is a function that accepts numbers (or number matrices) and operates on them using any operation
available in MATLAB.
This function can accept multiple variables.
However, the measurement that is the operand must have a matrix size in dim 1 matching the number of variables.

This operation is faster than the normal mathematical operations, and can handle more functions, but requires more lines of code.

Example:
```matlab
syms f(x,y)
f(x,y) = hypot(x,y);
m = Meas.from([3,6,9;4,8,12],0.1);
hy = m.apply(f); % "5±0.2" "10±0.2" "15±0.2"
```

For your convenience, you can use `Meas.scalar(num)` to get the function for multiplying by a scalar and 
`Meas.div` to get the function for division.

## Statistical Operations

This program also provides statistical operations, which act very similarly to statistical operations on number vectors.

**Supported Statistical Functions:**
- `mean`: calculates the arithmetic mean along dimension 2
- `sum`: sums all the elements along dimension 2
- `diff`: the numerical difference between neighbors in dimension 2
- `diff_mean`: applies the `mean` on the result of `diff`. Acts similar to calculating a slope, but useful for higher uncertainties.
- `integral`: applies a numerical integration on the matrix, where the elements `(1,:)` are the x values and `(2,:)` are 
   the y values.
- `running_avg_2`: the numerical difference between 2 neighbors in dimension 2

## Plotting and Regression Analysis

The program provides support for plotting and analyzing the relationship between measurements.
This is mostly done using the `fit` function.

### `Meas.fit(x,y,titles)`
Analyzes the relationship between `x`,`y` and to form linear regressions between them, which is then plotted in a new figure.

- `x` is a measurement matrix, and represents the independent value (the stuff on the x-axis)
  - dimension 1 represents different graphs
  - dimension 2 represents different entries *in the same graph*
  - the size of x in dimension 2 must match the size of y in dimension 2
  - the size of x in dimension 1 may either match the size of y in dimension 1 or be equal to 1 (where it will be duplicated to match the size of y).
- `y` is also a measurement matrix, and represents the dependent value (the stuff on the y-axis)
    - dimension 1 represents different graphs
    - dimension 2 represents different entries *in the same graph*
- `titles` is a title structure:
  - `titles.title`  controls the figure title
  - `titles.x_axis` controls the x-axis title
  - `titles.y_axis` controls the y-axis title
  - `titles.data`   controls the legend entry for each graph's points
  - `titles.fit`    controls the legend entry for each graph's regression line

**Customization in `titles`**:
- all entries in the `titles` struct are interpreted by a LaTeX compatible engine, so by surrounding the name with $, you use LaTeX:
  For example, "$\\phi_1$" will replace "\\phi" with the corresponding Greek letter and put 1 in subscript.
- `titles.data` and `titles.fit` control multiple entries, which can be specified in 2 ways:
  - vector: you can make a vector of strings in dimension 1, and each entry in the vector will be used for the 
    corresponding graph. For example, `["graph A"; "graph B"]`
  - scalar: if you put in a plain string without a vector, the string will apply to all graphs.
    In addition, the string `%d` will be transformed into the index of the graph in the list, starting from 1.
    For example, `"Attempt %d"`->`["Attempt 1"; "Attempt 2"]`
- If a certain fit in `titles.fit` is called `IGNORE`, then the regression line is not drawn (it is however, calculated)
- If a certain entry in `titles.data` contains the word "Regression", then the error bars are not drawn for that graph,
  and the points are connected as if the points represent a regression. This is particularly useful for theoretical lines.

**Customization in `x`,`y`**:
- if all entries in a particular graph are theoretical, i.e. have error `-1`, 
  then the error bars in that direction are ignored. If this is the case both in the x and y direction,
  then the points turn into circles.
- Any entry with error `-2` is completely ignored: not drawn, and not considered when calculating regressions.
  Acts like an empty space, useful for putting together graphs with different number of measurements.

**Result**:
- a new figure is created that draws the graphs provided with the customization specified.
  This does not delete the previous figure or modify it in any way. This cannot be suppressed.
- a specialized measurement matrix is created containing all the information about the regressions. Its dimensions are N*2,
  where N is the number of graphs. The type of this measurement is `FitMeas`, a sub-class of `Meas`, 
  which gives it additional functions and properties, specified below. This is the output of the function.

### `FitMeas#slope`
get the slopes of the regressions. Returns a measurement vector with the size of the number of graphs.

### `FitMeas#intercept`
get the y-intercepts of the regressions. Returns a measurement vector with the size of the number of graphs.

### `FitMeas#rsquare`
get the R^2 of the regressions. Returns a number vector with the size of the number of graphs.

### `FitMeas#sse`
get the sums of the squares of the errors of the regressions. Returns a number vector with the size of the number of graphs.
