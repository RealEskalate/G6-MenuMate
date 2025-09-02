"use client"
import * as React from "react"
import { cn } from "@/lib/utils"
import { Eye, EyeOff } from "lucide-react"

interface InputProps extends React.ComponentProps<"input"> {
  label?: string 
  required?: boolean
}

/*    you can use it as such if required just add the required and if label wanted add the label and pass and also there are differnt types which are Type	
text	General text entry	Standard keyboard
email	Email addresses	Email-specific keyboard
password	Sensitive or hidden input	Standard (hidden)
number	Quantities, ages, numeric	Numeric keypad
search	Search input fields	Search-specific keyboard
tel	Phone numbers	Phone keypad
url	Web addresses	URL-focused keyboard
file  <Input placeholder="input" label = "name" type = "password" required className=""/>*/


function Input({ className, type = "text", label, required, ...props }: InputProps) {
  const [showPassword, setShowPassword] = React.useState(false)
  const id = React.useId()

  const isPassword = type === "password"

  return (
    <div className="flex flex-col space-y-1 w-full">
      {label && (
        <label
          htmlFor={id}
          className="text-lg pb-1 text-gray-900 dark:text-gray-300"
        >
          {label}
          {required && <span className="text-red-500 ml-1">*</span>}
        </label>
      )}

      <div className="relative">
        <input
          id={id}
          type={isPassword && showPassword ? "text" : type}
          data-slot="input"
          required={required}
          className={cn(
            "file:text-foreground placeholder:text-muted-foreground selection:bg-[var(--color-primary)] selection:text-white",
            "dark:bg-input/30 border-input flex h-9 w-full min-w-0 rounded-md border bg-transparent px-3 py-1 text-base shadow-xs",
            "transition-[color,box-shadow] outline-none",
            "file:inline-flex file:h-7 file:border-0 file:bg-transparent file:text-sm file:font-medium",
            "disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50 md:text-sm",
            "focus-visible:border-[var(--color-primary)] focus-visible:ring-[var(--color-primary)]/40 focus-visible:ring-[1px]",
            "aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive",
            className
          )}
          {...props}
        />

        {/* Password toggle button */}
        {isPassword && (
          <button
            type="button"
            onClick={() => setShowPassword((prev) => !prev)}
            className="absolute inset-y-0 right-3 flex items-center text-gray-500 hover:text-[var(--color-primary)]"
          >
            {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
          </button>
        )}
      </div>
    </div>
  )
}

export { Input }
