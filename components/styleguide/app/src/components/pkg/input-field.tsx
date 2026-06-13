import React from 'react';

interface StyleGuideInputFieldProps {
  type?: string;
  placeholder?: string;
  value?: string;
  error?: boolean;
  disabled?: boolean;
  textarea?: boolean;
}

export function StyleGuideInputField({ type = 'text', placeholder, value, error, disabled, textarea }: StyleGuideInputFieldProps) {
  const classes = `input-field${textarea ? ' input-textarea' : ''}${error ? ' error' : ''}`;
  const style = disabled ? { opacity: 0.4, cursor: 'not-allowed' } : undefined;
  if (textarea) {
    return <textarea className={classes} placeholder={placeholder} defaultValue={value} disabled={disabled} style={style} />;
  }
  return <input type={type} className={classes} placeholder={placeholder} defaultValue={value} disabled={disabled} style={style} />;
}
