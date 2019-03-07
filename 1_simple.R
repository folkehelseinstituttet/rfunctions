# A function is something that lets you "do" something
c(1:5)
sum(c(1,2))
rep(c(1:5),each=5)

# There are 3 parts to a function:
# 1. "Give" something to the function (arguments)
# 2. "Do" something (the inside of the function)
# 3. "Receive" something back (return)
#
# Each of these parts are optional.
#
# You can create your own functions as follows:

MyNewFunction <- function(argument1, argument2){
  # do something
  print("Before")
  print(argument1)
  
  returnValue <- argument1+1
  
  print("After")
  print(returnValue)
  
  # return something (give something back)
  return(returnValue)
}

# We can now run the function:
b <- MyNewFunction(argument1=3, argument2=6)
print(b) # b contains the 'returnValue'

# If we don't provide the name of the argument,
# then the position is used 
# i.e. 
# 3 is given to the first argument,
# 6 is given to the second argument
MyNewFunction(3, 6)


# It is very important to understand that if you
# pass a variable to a function as an argument
# it cannot be changed. The *ONLY* way to 
# "get something out of a function" is to return it
Add1 <- function(x){
  x <- x + 1
}

myvariable <- 3
Add1(x=myvariable)
myvariable # myvariable is unchanged

# The *ONLY* way to 
# "get something out of a function"
# is to return it
Add1 <- function(x){
  x <- x + 1
  return(x)
}

myvariable <- 3
myvariable <- Add1(x=myvariable)
myvariable # myvariable is now 4


