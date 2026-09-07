---
paths:
  - "**/*.ts"
  - "**/*.tsx"
---
# SOLID Principles & Clean Code

> This file extends [typescript/coding-style.md](../typescript/coding-style.md) with SOLID principles and clean code patterns.

## SOLID Principles

### Single Responsibility Principle (SRP)

Each class, function, or module should have one reason to change.

```typescript
// WRONG: Multiple responsibilities
class UserService {
  async createUser(data: CreateUserDto) {
    // Validation
    if (!data.email) throw new Error('Email required')

    // Business logic
    const hashedPassword = await bcrypt.hash(data.password, 10)

    // Database
    const user = await prisma.user.create({
      data: { ...data, password: hashedPassword },
    })

    // Email
    await sendEmail(data.email, 'Welcome!')

    // Logging
    logger.info('User created', { userId: user.id })

    return user
  }
}

// CORRECT: Single responsibility
class UserValidator {
  validate(data: CreateUserDto): void {
    if (!data.email) throw new ValidationError('Email required')
    if (!data.password) throw new ValidationError('Password required')
  }
}

class PasswordHasher {
  async hash(password: string): Promise<string> {
    return bcrypt.hash(password, 10)
  }
}

class UserRepository {
  async create(data: CreateUserDto): Promise<User> {
    return prisma.user.create({ data })
  }
}

class EmailService {
  async sendWelcome(email: string): Promise<void> {
    await sendEmail(email, 'Welcome!')
  }
}

class UserService {
  constructor(
    private validator: UserValidator,
    private hasher: PasswordHasher,
    private repository: UserRepository,
    private emailService: EmailService
  ) {}

  async createUser(data: CreateUserDto): Promise<User> {
    this.validator.validate(data)
    const hashedPassword = await this.hasher.hash(data.password)
    const user = await this.repository.create({
      ...data,
      password: hashedPassword,
    })
    await this.emailService.sendWelcome(data.email)
    return user
  }
}
```

### Open/Closed Principle (OCP)

Open for extension, closed for modification.

```typescript
// WRONG: Must modify class to add new notification types
class NotificationService {
  send(userId: string, message: string, type: 'email' | 'sms' | 'push') {
    if (type === 'email') {
      // Email logic
    } else if (type === 'sms') {
      // SMS logic
    } else if (type === 'push') {
      // Push logic
    }
  }
}

// CORRECT: Open for extension via interfaces
interface NotificationChannel {
  send(userId: string, message: string): Promise<void>
}

class EmailNotification implements NotificationChannel {
  async send(userId: string, message: string): Promise<void> {
    // Email logic
  }
}

class SMSNotification implements NotificationChannel {
  async send(userId: string, message: string): Promise<void> {
    // SMS logic
  }
}

class PushNotification implements NotificationChannel {
  async send(userId: string, message: string): Promise<void> {
    // Push logic
  }
}

class NotificationService {
  private channels: Map<string, NotificationChannel> = new Map()

  registerChannel(name: string, channel: NotificationChannel) {
    this.channels.set(name, channel)
  }

  async send(
    userId: string,
    message: string,
    channelName: string
  ): Promise<void> {
    const channel = this.channels.get(channelName)
    if (!channel) throw new Error(`Channel ${channelName} not found`)
    await channel.send(userId, message)
  }
}

// Usage - easy to add new channels
const notificationService = new NotificationService()
notificationService.registerChannel('email', new EmailNotification())
notificationService.registerChannel('sms', new SMSNotification())
notificationService.registerChannel('push', new PushNotification())
```

### Liskov Substitution Principle (LSP)

Subtypes must be substitutable for their base types.

```typescript
// WRONG: Violates LSP - square behaves differently
class Rectangle {
  constructor(protected width: number, protected height: number) {}

  setWidth(width: number) {
    this.width = width
  }

  setHeight(height: number) {
    this.height = height
  }

  getArea(): number {
    return this.width * this.height
  }
}

class Square extends Rectangle {
  setWidth(width: number) {
    this.width = width
    this.height = width // Changes height too!
  }

  setHeight(height: number) {
    this.width = height
    this.height = height // Changes width too!
  }
}

// CORRECT: Use composition or immutable types
interface Shape {
  getArea(): number
}

class Rectangle implements Shape {
  constructor(
    private readonly width: number,
    private readonly height: number
  ) {}

  getArea(): number {
    return this.width * this.height
  }
}

class Square implements Shape {
  constructor(private readonly side: number) {}

  getArea(): number {
    return this.side * this.side
  }
}

// Both are substitutable for Shape
function calculateArea(shape: Shape): number {
  return shape.getArea()
}
```

### Interface Segregation Principle (ISP)

Clients shouldn't be forced to depend on interfaces they don't use.

```typescript
// WRONG: Fat interface
interface UserService {
  createUser(data: CreateUserDto): Promise<User>
  updateUser(id: string, data: UpdateUserDto): Promise<User>
  deleteUser(id: string): Promise<void>
  getUser(id: string): Promise<User>
  getUserByEmail(email: string): Promise<User>
  sendPasswordReset(email: string): Promise<void>
  verifyEmail(token: string): Promise<void>
  updatePassword(id: string, password: string): Promise<void>
  getAuditLog(id: string): Promise<AuditLog[]>
}

// CORRECT: Segregated interfaces
interface UserCreator {
  createUser(data: CreateUserDto): Promise<User>
}

interface UserReader {
  getUser(id: string): Promise<User>
  getUserByEmail(email: string): Promise<User>
}

interface UserUpdater {
  updateUser(id: string, data: UpdateUserDto): Promise<User>
  updatePassword(id: string, password: string): Promise<void>
}

interface UserDeleter {
  deleteUser(id: string): Promise<void>
}

interface EmailVerifier {
  sendPasswordReset(email: string): Promise<void>
  verifyEmail(token: string): Promise<void>
}

// Use only what's needed
class UserRegistrationService implements UserCreator, EmailVerifier {
  constructor(
    private repository: UserCreator & EmailVerifier
  ) {}

  async createUser(data: CreateUserDto): Promise<User> {
    return this.repository.createUser(data)
  }

  async sendPasswordReset(email: string): Promise<void> {
    return this.repository.sendPasswordReset(email)
  }

  async verifyEmail(token: string): Promise<void> {
    return this.repository.verifyEmail(token)
  }
}
```

### Dependency Inversion Principle (DIP)

Depend on abstractions, not concretions.

```typescript
// WRONG: Depends on concrete implementation
class UserService {
  private prisma = new PrismaClient() // Tight coupling

  async createUser(data: CreateUserDto) {
    return this.prisma.user.create({ data })
  }
}

// CORRECT: Depends on abstraction
interface UserRepository {
  create(data: CreateUserDto): Promise<User>
  findById(id: string): Promise<User | null>
  findByEmail(email: string): Promise<User | null>
}

class PrismaUserRepository implements UserRepository {
  constructor(private prisma: PrismaClient) {}

  async create(data: CreateUserDto): Promise<User> {
    return this.prisma.user.create({ data })
  }

  async findById(id: string): Promise<User | null> {
    return this.prisma.user.findUnique({ where: { id } })
  }

  async findByEmail(email: string): Promise<User | null> {
    return this.prisma.user.findUnique({ where: { email } })
  }
}

// Dependency injection
class UserService {
  constructor(private repository: UserRepository) {}

  async createUser(data: CreateUserDto): Promise<User> {
    return this.repository.create(data)
  }
}

// Easy to test with mock
const mockRepository: UserRepository = {
  create: jest.fn(),
  findById: jest.fn(),
  findByEmail: jest.fn(),
}

const service = new UserService(mockRepository)
```

## Clean Code Patterns

### Meaningful Names

```typescript
// WRONG: Unclear names
function d(a: number, b: number): number {
  return a * b
}

const x = new Map()
const fn = (e: any) => { /* ... */ }

// CORRECT: Intention-revealing names
function calculateArea(width: number, height: number): number {
  return width * height
}

const userSessions = new Map<string, Session>()

const handleUserRegistration = (event: RegistrationEvent) => {
  /* ... */
}
```

### Small Functions

```typescript
// WRONG: Long function
async function processOrder(order: Order) {
  // 50+ lines of validation, calculation, database operations,
  // email sending, inventory updates, etc.
}

// CORRECT: Small, focused functions
async function processOrder(order: Order): Promise<OrderResult> {
  const validatedOrder = validateOrder(order)
  const calculatedOrder = calculateTotal(validatedOrder)
  const savedOrder = await saveOrder(calculatedOrder)
  await updateInventory(savedOrder)
  await sendConfirmationEmail(savedOrder)
  await logOrderProcessing(savedOrder)

  return savedOrder
}

function validateOrder(order: Order): ValidatedOrder {
  // Validation logic only
}

function calculateTotal(order: ValidatedOrder): CalculatedOrder {
  // Calculation logic only
}

async function saveOrder(order: CalculatedOrder): Promise<SavedOrder> {
  // Database logic only
}
```

### Function Arguments

```typescript
// WRONG: Too many arguments
function createUser(
  name: string,
  email: string,
  password: string,
  age: number,
  role: string,
  department: string,
  manager: string
) {
  // ...
}

// CORRECT: Use options object
interface CreateUserOptions {
  name: string
  email: string
  password: string
  age: number
  role: string
  department: string
  manager?: string
}

function createUser(options: CreateUserOptions): Promise<User> {
  // ...
}

// Usage
createUser({
  name: 'John',
  email: 'john@example.com',
  password: 'securePassword',
  age: 30,
  role: 'developer',
  department: 'engineering',
})
```

### Guard Clauses

```typescript
// WRONG: Deep nesting
function processPayment(order: Order): PaymentResult {
  if (order.items.length > 0) {
    if (order.customer) {
      if (order.paymentMethod) {
        if (order.total > 0) {
          // Main logic buried deep
          return chargePayment(order)
        } else {
          return { success: false, error: 'Invalid total' }
        }
      } else {
        return { success: false, error: 'No payment method' }
      }
    } else {
      return { success: false, error: 'No customer' }
    }
  } else {
    return { success: false, error: 'No items' }
  }
}

// CORRECT: Guard clauses
function processPayment(order: Order): PaymentResult {
  if (order.items.length === 0) {
    return { success: false, error: 'No items' }
  }

  if (!order.customer) {
    return { success: false, error: 'No customer' }
  }

  if (!order.paymentMethod) {
    return { success: false, error: 'No payment method' }
  }

  if (order.total <= 0) {
    return { success: false, error: 'Invalid total' }
  }

  return chargePayment(order)
}
```

### Pure Functions

```typescript
// WRONG: Side effects
let taxRate = 0.1

function calculateTax(amount: number): number {
  taxRate = 0.15 // Modifies external state
  return amount * taxRate
}

// CORRECT: Pure function
function calculateTax(amount: number, taxRate: number): number {
  return amount * taxRate
}

// Usage
const tax = calculateTax(100, 0.15) // Predictable
```

### Immutability

```typescript
// WRONG: Mutation
interface User {
  name: string
  email: string
  settings: UserSettings
}

function updateUser(user: User, updates: Partial<User>): User {
  Object.assign(user, updates) // Mutates original
  return user
}

// CORRECT: Immutable updates
function updateUser(user: Readonly<User>, updates: Partial<User>): User {
  return {
    ...user,
    ...updates,
    settings: {
      ...user.settings,
      ...(updates.settings || {}),
    },
  }
}

// Using Readonly for enforcement
interface ImmutableUser {
  readonly id: string
  readonly name: string
  readonly email: string
}
```

### Composition Over Inheritance

```typescript
// WRONG: Deep inheritance hierarchy
class Animal {}
class Mammal extends Animal {}
class Dog extends Mammal {}
class GuideDog extends Dog {}

// CORRECT: Composition
interface Logger {
  log(message: string): void
}

interface Authenticator {
  authenticate(token: string): Promise<User>
}

interface Authorizer {
  authorize(user: User, action: string): boolean
}

class AuthService {
  constructor(
    private logger: Logger,
    private authenticator: Authenticator,
    private authorizer: Authorizer
  ) {}

  async handleRequest(token: string, action: string): Promise<User> {
    this.logger.log(`Authenticating request for action: ${action}`)

    const user = await this.authenticator.authenticate(token)
    this.logger.log(`User authenticated: ${user.id}`)

    if (!this.authorizer.authorize(user, action)) {
      throw new Error('Unauthorized')
    }

    return user
  }
}
```

## Checklist

- [ ] Classes have single responsibility
- [ ] Code is open for extension, closed for modification
- [ ] Subtypes are substitutable for base types
- [ ] Interfaces are segregated
- [ ] Dependencies are inverted (depend on abstractions)
- [ ] Names are meaningful and intention-revealing
- [ ] Functions are small and focused
- [ ] Functions have few arguments (use options objects)
- [ ] Guard clauses reduce nesting
- [ ] Functions are pure when possible
- [ ] Data is immutable
- [ ] Composition is preferred over inheritance
