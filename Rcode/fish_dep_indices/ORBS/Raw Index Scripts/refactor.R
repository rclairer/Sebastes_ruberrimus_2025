refactor <- function(df, exclude = c(NA, ""))
{
       if(is.null(dim(df)))
               if(is.factor(df))
                       factor(as.character(df), exclude = exclude)
               else df
       else {
               data.frame(lapply(df, function(x)
               if(is.factor(x)) factor(as.character(x), exclude = exclude) else x))
       }
}

