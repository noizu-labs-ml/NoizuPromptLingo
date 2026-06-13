# Worked Example: Multi-Step Form Wizard with Deep Linking

## Scenario

A multi-step checkout wizard with:
- Step 1: Shipping information
- Step 2: Payment method
- Step 3: Order review
- Step 4: Confirmation
- Deep linking: each step reflected in URL
- Back button support: navigating back preserves form state
- Browser refresh: form state survives page reload
- Sharing: URL can be shared (for resuming a draft order)

---

## URL Structure

```
/checkout/shipping        # Step 1
/checkout/payment         # Step 2
/checkout/review          # Step 3
/checkout/confirmation    # Step 4 (read-only, order ID in URL)
```

---

## Step 1: Form State Management

```tsx
// stores/checkout-store.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

export interface ShippingInfo {
  firstName: string;
  lastName: string;
  address1: string;
  address2: string;
  city: string;
  state: string;
  zipCode: string;
  country: string;
  phone: string;
}

export interface PaymentInfo {
  cardNumber: string; // last 4 only in store
  cardholderName: string;
  expiryMonth: string;
  expiryYear: string;
  billingAddressSameAsShipping: boolean;
  billingAddress?: Omit<ShippingInfo, 'phone'>;
}

export interface CheckoutState {
  // Form data
  shipping: ShippingInfo;
  payment: PaymentInfo;
  shippingMethod: 'standard' | 'express' | 'overnight';

  // Wizard state
  currentStep: number;
  completedSteps: number[];

  // Order result
  orderId: string | null;

  // Actions
  setShipping: (data: Partial<ShippingInfo>) => void;
  setPayment: (data: Partial<PaymentInfo>) => void;
  setShippingMethod: (method: 'standard' | 'express' | 'overnight') => void;
  completeStep: (step: number) => void;
  goToStep: (step: number) => void;
  setOrderId: (id: string) => void;
  reset: () => void;
}

const initialShipping: ShippingInfo = {
  firstName: '',
  lastName: '',
  address1: '',
  address2: '',
  city: '',
  state: '',
  zipCode: '',
  country: 'US',
  phone: '',
};

const initialPayment: PaymentInfo = {
  cardNumber: '',
  cardholderName: '',
  expiryMonth: '',
  expiryYear: '',
  billingAddressSameAsShipping: true,
};

export const useCheckoutStore = create<CheckoutState>()(
  persist(
    (set) => ({
      shipping: initialShipping,
      payment: initialPayment,
      shippingMethod: 'standard',
      currentStep: 0,
      completedSteps: [],
      orderId: null,

      setShipping: (data) =>
        set((state) => ({ shipping: { ...state.shipping, ...data } })),

      setPayment: (data) =>
        set((state) => ({ payment: { ...state.payment, ...data } })),

      setShippingMethod: (shippingMethod) => set({ shippingMethod }),

      completeStep: (step) =>
        set((state) => ({
          completedSteps: state.completedSteps.includes(step)
            ? state.completedSteps
            : [...state.completedSteps, step],
        })),

      goToStep: (step) => set({ currentStep: step }),

      setOrderId: (orderId) => set({ orderId }),

      reset: () =>
        set({
          shipping: initialShipping,
          payment: initialPayment,
          shippingMethod: 'standard',
          currentStep: 0,
          completedSteps: [],
          orderId: null,
        }),
    }),
    {
      name: 'gnp-checkout',
      // Don't persist sensitive payment data in production
      // Only persist shipping and wizard state for resume functionality
      partialize: (state) => ({
        shipping: state.shipping,
        shippingMethod: state.shippingMethod,
        currentStep: state.currentStep,
        completedSteps: state.completedSteps,
        orderId: state.orderId,
      }),
    }
  )
);
```

---

## Step 2: Wizard Layout with URL Sync

```tsx
// app/checkout/layout.tsx
import { Suspense } from 'react';
import { CheckoutWizardLayout } from './checkout-wizard-layout';

export default function CheckoutLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="max-w-3xl mx-auto px-4 py-8">
      <h1 className="text-2xl font-bold mb-8">Checkout</h1>
      <Suspense fallback={<WizardSkeleton />}>
        <CheckoutWizardLayout>
          {children}
        </CheckoutWizardLayout>
      </Suspense>
    </div>
  );
}
```

```tsx
// app/checkout/checkout-wizard-layout.tsx
'use client';

import { useEffect } from 'react';
import { usePathname, useRouter } from 'next/navigation';
import { useCheckoutStore } from '@/stores/checkout-store';

const STEPS = [
  { path: '/checkout/shipping', label: 'Shipping', number: 0 },
  { path: '/checkout/payment', label: 'Payment', number: 1 },
  { path: '/checkout/review', label: 'Review', number: 2 },
  { path: '/checkout/confirmation', label: 'Confirmation', number: 3 },
];

export function CheckoutWizardLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const { completedSteps, currentStep, goToStep } = useCheckoutStore();

  // Sync URL to store on mount and navigation
  const currentStepIndex = STEPS.findIndex((step) => pathname === step.path);

  useEffect(() => {
    if (currentStepIndex >= 0 && currentStepIndex !== currentStep) {
      goToStep(currentStepIndex);
    }
  }, [currentStepIndex, currentStep, goToStep]);

  // Prevent jumping ahead to uncompleted steps
  useEffect(() => {
    if (currentStepIndex > 0) {
      const previousCompleted = completedSteps.includes(currentStepIndex - 1);
      if (!previousCompleted && currentStepIndex !== 0) {
        // Redirect to the last completed step + 1
        const lastCompleted = Math.max(-1, ...completedSteps);
        const targetStep = Math.min(lastCompleted + 1, STEPS.length - 1);
        router.replace(STEPS[targetStep].path);
      }
    }
  }, [currentStepIndex, completedSteps, router]);

  return (
    <div>
      {/* Step indicator */}
      <nav aria-label="Checkout progress" className="mb-8">
        <ol className="flex items-center justify-between">
          {STEPS.map((step, index) => {
            const isActive = index === currentStepIndex;
            const isCompleted = completedSteps.includes(index);
            const isAccessible = index <= Math.max(-1, ...completedSteps) + 1 || isCompleted;

            return (
              <li key={step.path} className="flex items-center">
                <button
                  onClick={() => {
                    if (isAccessible) router.push(step.path);
                  }}
                  disabled={!isAccessible}
                  className={`
                    flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium
                    ${isActive ? 'bg-blue-600 text-white' : ''}
                    ${isCompleted && !isActive ? 'bg-green-100 text-green-800' : ''}
                    ${!isActive && !isCompleted ? 'bg-gray-100 text-gray-400' : ''}
                    ${isAccessible && !isActive ? 'cursor-pointer hover:bg-gray-200' : ''}
                    ${!isAccessible ? 'cursor-not-allowed' : ''}
                  `}
                  aria-current={isActive ? 'step' : undefined}
                >
                  <span
                    className={`
                      w-6 h-6 rounded-full flex items-center justify-center text-xs
                      ${isCompleted ? 'bg-green-600 text-white' : ''}
                      ${isActive && !isCompleted ? 'bg-blue-600 text-white' : ''}
                      ${!isActive && !isCompleted ? 'bg-gray-300 text-gray-600' : ''}
                    `}
                  >
                    {isCompleted ? '✓' : index + 1}
                  </span>
                  <span className="hidden sm:inline">{step.label}</span>
                </button>
                {index < STEPS.length - 1 && (
                  <div className="w-8 h-px bg-gray-300 mx-2" aria-hidden="true" />
                )}
              </li>
            );
          })}
        </ol>
      </nav>

      {/* Step content */}
      <div>{children}</div>
    </div>
  );
}
```

---

## Step 3: Shipping Step

```tsx
// app/checkout/shipping/page.tsx
'use client';

import { useCallback } from 'react';
import { useRouter } from 'next/navigation';
import { useCheckoutStore } from '@/stores/checkout-store';
import { ShippingForm } from './shipping-form';

export default function ShippingStep() {
  const router = useRouter();
  const { shipping, setShipping, setShippingMethod, completeStep } = useCheckoutStore();

  const handleSubmit = useCallback(
    async (data: ShippingInfo) => {
      // Validate server-side
      const response = await fetch('/api/checkout/validate-shipping', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      });

      if (!response.ok) {
        const error = await response.json();
        // Show validation errors
        return { error: error.message };
      }

      // Save to store and advance
      setShipping(data);
      completeStep(0);
      router.push('/checkout/payment');
      return { success: true };
    },
    [setShipping, completeStep, router]
  );

  return (
    <div>
      <h2 className="text-xl font-semibold mb-4">Shipping Information</h2>
      <ShippingForm
        initialData={shipping}
        onSubmit={handleSubmit}
        onShippingMethodChange={setShippingMethod}
      />
    </div>
  );
}
```

```tsx
// app/checkout/shipping/shipping-form.tsx
'use client';

import { useState } from 'react';
import type { ShippingInfo } from '@/stores/checkout-store';

interface ShippingFormProps {
  initialData: ShippingInfo;
  onSubmit: (data: ShippingInfo) => Promise<{ success?: boolean; error?: string }>;
  onShippingMethodChange: (method: 'standard' | 'express' | 'overnight') => void;
}

export function ShippingForm({ initialData, onSubmit, onShippingMethodChange }: ShippingFormProps) {
  const [formData, setFormData] = useState(initialData);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [isSubmitting, setIsSubmitting] = useState(false);

  function handleChange(e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
    // Clear field error on change
    if (errors[name]) {
      setErrors((prev) => {
        const next = { ...prev };
        delete next[name];
        return next;
      });
    }
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();

    // Client-side validation
    const fieldErrors: Record<string, string> = {};
    if (!formData.firstName.trim()) fieldErrors.firstName = 'First name is required';
    if (!formData.lastName.trim()) fieldErrors.lastName = 'Last name is required';
    if (!formData.address1.trim()) fieldErrors.address1 = 'Address is required';
    if (!formData.city.trim()) fieldErrors.city = 'City is required';
    if (!formData.state.trim()) fieldErrors.state = 'State is required';
    if (!formData.zipCode.trim()) fieldErrors.zipCode = 'ZIP code is required';

    if (Object.keys(fieldErrors).length > 0) {
      setErrors(fieldErrors);
      return;
    }

    setIsSubmitting(true);
    const result = await onSubmit(formData);
    setIsSubmitting(false);

    if (result.error) {
      setErrors({ form: result.error });
    }
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      {errors.form && (
        <div className="p-3 bg-red-50 text-red-700 rounded-lg" role="alert">
          {errors.form}
        </div>
      )}

      <div className="grid grid-cols-2 gap-4">
        <div>
          <label htmlFor="firstName" className="block text-sm font-medium mb-1">
            First Name
          </label>
          <input
            id="firstName"
            name="firstName"
            value={formData.firstName}
            onChange={handleChange}
            className={`w-full rounded-lg border px-3 py-2 ${
              errors.firstName ? 'border-red-500' : 'border-gray-300'
            }`}
            aria-invalid={!!errors.firstName}
            aria-describedby={errors.firstName ? 'firstName-error' : undefined}
          />
          {errors.firstName && (
            <p id="firstName-error" className="text-sm text-red-600 mt-1">
              {errors.firstName}
            </p>
          )}
        </div>
        {/* ... more fields following same pattern ... */}
      </div>

      {/* Shipping method selection */}
      <fieldset>
        <legend className="text-sm font-medium mb-2">Shipping Method</legend>
        <div className="space-y-2">
          {[
            { value: 'standard', label: 'Standard (5-7 days)', price: '$5.99' },
            { value: 'express', label: 'Express (2-3 days)', price: '$14.99' },
            { value: 'overnight', label: 'Overnight', price: '$29.99' },
          ].map((method) => (
            <label key={method.value} className="flex items-center gap-3 p-3 border rounded-lg cursor-pointer">
              <input
                type="radio"
                name="shippingMethod"
                value={method.value}
                onChange={(e) => onShippingMethodChange(e.target.value as 'standard' | 'express' | 'overnight')}
              />
              <span className="flex-1">{method.label}</span>
              <span className="font-medium">{method.price}</span>
            </label>
          ))}
        </div>
      </fieldset>

      <button
        type="submit"
        disabled={isSubmitting}
        className="w-full py-3 bg-blue-600 text-white rounded-lg font-medium hover:bg-blue-700 disabled:opacity-50"
      >
        {isSubmitting ? 'Saving...' : 'Continue to Payment'}
      </button>
    </form>
  );
}
```

---

## Step 4: Payment Step

```tsx
// app/checkout/payment/page.tsx
'use client';

import { useCallback } from 'react';
import { useRouter } from 'next/navigation';
import { useCheckoutStore } from '@/stores/checkout-store';

export default function PaymentStep() {
  const router = useRouter();
  const { payment, setPayment, completeStep } = useCheckoutStore();

  const handleSubmit = useCallback(
    async (data: PaymentInfo) => {
      // Tokenize card via payment provider (Stripe, etc.)
      // NEVER store full card number — only token and last 4
      const response = await fetch('/api/checkout/tokenize-card', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      });

      if (!response.ok) {
        const error = await response.json();
        return { error: error.message };
      }

      const { token, last4 } = await response.json();

      setPayment({
        ...data,
        cardNumber: last4, // Store only last 4 digits
      });
      completeStep(1);
      router.push('/checkout/review');
      return { success: true };
    },
    [setPayment, completeStep, router]
  );

  return (
    <div>
      <h2 className="text-xl font-semibold mb-4">Payment Method</h2>
      <PaymentForm initialData={payment} onSubmit={handleSubmit} />
    </div>
  );
}
```

---

## Step 5: Review Step

```tsx
// app/checkout/review/page.tsx
'use client';

import { useCheckoutStore } from '@/stores/checkout-store';
import { useRouter } from 'next/navigation';
import { useState } from 'react';

export default function ReviewStep() {
  const router = useRouter();
  const { shipping, payment, shippingMethod, completeStep, setOrderId, reset } =
    useCheckoutStore();
  const [isSubmitting, setIsSubmitting] = useState(false);

  async function handlePlaceOrder() {
    setIsSubmitting(true);
    try {
      const response = await fetch('/api/checkout/place-order', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          shipping,
          shippingMethod,
          paymentToken: payment.cardNumber, // token from payment provider
        }),
      });

      if (!response.ok) {
        const error = await response.json();
        alert(error.message);
        return;
      }

      const { orderId } = await response.json();
      completeStep(2);
      setOrderId(orderId);
      router.push(`/checkout/confirmation?orderId=${orderId}`);
    } catch {
      alert('Failed to place order. Please try again.');
    } finally {
      setIsSubmitting(false);
    }
  }

  const shippingCost =
    shippingMethod === 'overnight' ? 29.99 : shippingMethod === 'express' ? 14.99 : 5.99;

  return (
    <div className="space-y-6">
      <h2 className="text-xl font-semibold">Review Your Order</h2>

      {/* Shipping Summary */}
      <section className="border rounded-lg p-4">
        <div className="flex justify-between items-center mb-2">
          <h3 className="font-medium">Shipping Address</h3>
          <button
            onClick={() => router.push('/checkout/shipping')}
            className="text-blue-600 text-sm"
          >
            Edit
          </button>
        </div>
        <p className="text-sm text-gray-600">
          {shipping.firstName} {shipping.lastName}<br />
          {shipping.address1}<br />
          {shipping.address2 && <>{shipping.address2}<br /></>}
          {shipping.city}, {shipping.state} {shipping.zipCode}<br />
          {shipping.phone}
        </p>
        <p className="text-sm text-gray-600 mt-2">
          Shipping: {shippingMethod.charAt(0).toUpperCase() + shippingMethod.slice(1)} (${shippingCost})
        </p>
      </section>

      {/* Payment Summary */}
      <section className="border rounded-lg p-4">
        <div className="flex justify-between items-center mb-2">
          <h3 className="font-medium">Payment Method</h3>
          <button
            onClick={() => router.push('/checkout/payment')}
            className="text-blue-600 text-sm"
          >
            Edit
          </button>
        </div>
        <p className="text-sm text-gray-600">
          Card ending in {payment.cardNumber}<br />
          {payment.cardholderName}
        </p>
      </section>

      <button
        onClick={handlePlaceOrder}
        disabled={isSubmitting}
        className="w-full py-3 bg-green-600 text-white rounded-lg font-medium hover:bg-green-700 disabled:opacity-50"
      >
        {isSubmitting ? 'Placing Order...' : 'Place Order'}
      </button>
    </div>
  );
}
```

---

## Step 6: Confirmation Step

```tsx
// app/checkout/confirmation/page.tsx
'use client';

import { useSearchParams } from 'next/navigation';
import { useCheckoutStore } from '@/stores/checkout-store';
import { useEffect } from 'react';

export default function ConfirmationStep() {
  const searchParams = useSearchParams();
  const orderId = searchParams.get('orderId');
  const { reset } = useCheckoutStore();

  // Clear checkout state after showing confirmation
  useEffect(() => {
    if (orderId) {
      // Delay reset so the page renders first
      const timer = setTimeout(reset, 5000);
      return () => clearTimeout(timer);
    }
  }, [orderId, reset]);

  if (!orderId) {
    return (
      <div className="text-center py-12">
        <h2 className="text-xl">Order not found</h2>
        <p className="text-gray-500 mt-2">Please check your order confirmation email.</p>
      </div>
    );
  }

  return (
    <div className="text-center py-12">
      <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
        <svg className="w-8 h-8 text-green-600" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
        </svg>
      </div>
      <h2 className="text-2xl font-bold">Order Confirmed!</h2>
      <p className="text-gray-600 mt-2">
        Your order <strong>#{orderId}</strong> has been placed successfully.
      </p>
      <p className="text-gray-500 mt-1">
        You will receive a confirmation email shortly.
      </p>
      <a
        href={`/orders/${orderId}`}
        className="inline-block mt-6 px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700"
      >
        View Order Details
      </a>
    </div>
  );
}
```

---

## Step 7: Server Action for Order Validation

```tsx
// actions/checkout-actions.ts
import { z } from 'zod';

const shippingSchema = z.object({
  firstName: z.string().min(1).max(50),
  lastName: z.string().min(1).max(50),
  address1: z.string().min(1).max(200),
  address2: z.string().max(200).optional(),
  city: z.string().min(1).max(100),
  state: z.string().min(1).max(50),
  zipCode: z.string().regex(/^\d{5}(-\d{4})?$/, 'Invalid ZIP code'),
  country: z.string().length(2),
  phone: z.string().regex(/^\+?[\d\s()-]{10,}$/, 'Invalid phone number'),
});

export async function validateShipping(data: unknown) {
  const session = await getServerSession();
  if (!session?.user) {
    return { error: 'Please sign in to continue checkout' };
  }

  const result = shippingSchema.safeParse(data);
  if (!result.success) {
    return { error: 'Invalid shipping information', fields: result.error.flatten().fieldErrors };
  }

  // Additional server-side validation (e.g., address verification)
  const addressValid = await verifyAddress(result.data);
  if (!addressValid.valid) {
    return { error: 'Address could not be verified. Please check and try again.' };
  }

  return { success: true };
}
```

---

## Test Cases for Back-Button Behavior

```tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { useRouter, useSearchParams, usePathname } from 'next/navigation';

jest.mock('next/navigation', () => ({
  useRouter: jest.fn(),
  useSearchParams: jest.fn(),
  usePathname: jest.fn(),
}));

describe('Checkout wizard navigation', () => {
  const push = jest.fn();
  const replace = jest.fn();

  beforeEach(() => {
    jest.clearAllMocks();
    (useRouter as jest.Mock).mockReturnValue({ push, replace });
    (usePathname as jest.Mock).mockReturnValue('/checkout/shipping');
    (useSearchParams as jest.Mock).mockReturnValue(new URLSearchParams());
  });

  test('submitting shipping advances to payment', async () => {
    render(<ShippingStep />);

    // Fill in required fields
    fireEvent.change(screen.getByLabelText(/first name/i), { target: { value: 'John' } });
    fireEvent.change(screen.getByLabelText(/last name/i), { target: { value: 'Doe' } });
    // ... fill other fields

    fireEvent.click(screen.getByRole('button', { name: /continue to payment/i }));

    await waitFor(() => {
      expect(push).toHaveBeenCalledWith('/checkout/payment');
    });
  });

  test('navigating to review without completing payment redirects back', () => {
    (usePathname as jest.Mock).mockReturnValue('/checkout/review');

    render(<CheckoutWizardLayout><div /></CheckoutWizardLayout>);

    expect(replace).toHaveBeenCalledWith('/checkout/shipping');
  });

  test('completed steps are accessible from step indicator', () => {
    // Simulate having completed step 0
    useCheckoutStore.setState({ completedSteps: [0] });
    (usePathname as jest.Mock).mockReturnValue('/checkout/payment');

    render(<CheckoutWizardLayout><div /></CheckoutWizardLayout>);

    // Shipping step should be clickable
    const shippingButton = screen.getByText('Shipping').closest('button')!;
    expect(shippingButton).not.toBeDisabled();
  });
});
```

---

## Edge Cases

### Browser Refresh Mid-Wizard

The Zustand persist middleware ensures form data survives refresh. The URL determines which step to show. On mount, the wizard checks if the current step has been reached legitimately:

```tsx
// In checkout-wizard-layout.tsx
useEffect(() => {
  // On refresh, restore step from URL
  const stepFromUrl = STEPS.findIndex((s) => s.path === pathname);
  if (stepFromUrl >= 0) {
    goToStep(stepFromUrl);
  }
}, [pathname, goToStep]);
```

### Sharing Deep-Linked State

The confirmation URL (`/checkout/confirmation?orderId=abc123`) is shareable. The order ID is a public identifier (not a secret), and the confirmation page only shows minimal details. Full order details require authentication at `/orders/[id]`.

### Session Expiry During Checkout

```tsx
// In each step, before submitting
const session = await getServerSession();
if (!session) {
  // Save current state (already persisted via Zustand)
  // Redirect to login with return URL
  router.push(`/login?returnTo=${encodeURIComponent(pathname)}`);
  return;
}
```

### Concurrent Tab Issues

If the user opens checkout in two tabs, Zustand persist can cause conflicts. Mitigate with storage event listening:

```tsx
// Listen for storage changes from other tabs
useEffect(() => {
  function handleStorageChange(e: StorageEvent) {
    if (e.key === 'gnp-checkout') {
      // Re-hydrate from storage
      useCheckoutStore.persist.rehydrate();
    }
  }

  window.addEventListener('storage', handleStorageChange);
  return () => window.removeEventListener('storage', handleStorageChange);
}, []);
```
