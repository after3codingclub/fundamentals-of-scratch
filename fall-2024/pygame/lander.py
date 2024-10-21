import pygame
import math

# Initialize Pygame
pygame.init()

# Constants
WIDTH, HEIGHT = 800, 600
GRAVITY = 0.05
THRUST = -0.15
LANDER_WIDTH, LANDER_HEIGHT = 40, 20
FPS = 60

# Colors
BLACK = (0, 0, 0)
WHITE = (255, 255, 255)
RED = (255, 0, 0)
GREEN = (0, 255, 0)

# Set up display
screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("Lunar Lander")

# Load lander image (simple rectangle as placeholder)
lander_image = pygame.Surface((LANDER_WIDTH, LANDER_HEIGHT))
lander_image.fill(WHITE)

# Platform
platform = pygame.Rect(WIDTH // 2 - 50, HEIGHT - 50, 100, 10)

# Lander class
class Lander:
    def __init__(self):
        self.x = WIDTH // 2
        self.y = HEIGHT // 4
        self.vx = 0
        self.vy = 0
        self.angle = 0  # Angle of the lander in degrees
        self.fuel = 100
        self.landed = False  # Add a flag to mark if the lander has landed/crashed

    def update(self, thrusting, rotating):
        if not self.landed:
            # Apply gravity
            self.vy += GRAVITY

            # Apply thrust
            if thrusting and self.fuel > 0:
                self.vx += THRUST * math.sin(math.radians(self.angle))
                self.vy += THRUST * math.cos(math.radians(self.angle))
                self.fuel -= 0.5  # Decrease fuel

            # Apply rotation
            self.angle += rotating

            # Update position
            self.x += self.vx
            self.y += self.vy

            # Keep the lander on screen horizontally
            if self.x < 0:
                self.x = WIDTH
            elif self.x > WIDTH:
                self.x = 0

    def draw(self):
        # Rotate the lander image
        rotated_image = pygame.transform.rotate(lander_image, self.angle)
        new_rect = rotated_image.get_rect(center=(self.x, self.y))
        screen.blit(rotated_image, new_rect.topleft)

    def check_landing(self):
        lander_rect = pygame.Rect(self.x - LANDER_WIDTH // 2, self.y - LANDER_HEIGHT // 2, LANDER_WIDTH, LANDER_HEIGHT)
        if lander_rect.colliderect(platform):
            # Successful landing if vertical speed is low
            if abs(self.vy) < 1 and abs(self.vx) < 1 and abs(self.angle) < 15:
                self.landed = True  # Mark as landed
                return "landed"
            else:
                self.landed = True  # Mark as crashed
                return "crashed"
        return None

# Main game loop
def main():
    clock = pygame.time.Clock()
    lander = Lander()
    running = True
    thrusting = False
    rotating = 0
    game_over = False
    result = None

    while running:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False

            # Key events
            if not game_over:
                if event.type == pygame.KEYDOWN:
                    if event.key == pygame.K_UP:
                        thrusting = True
                    if event.key == pygame.K_LEFT:
                        rotating = 1
                    if event.key == pygame.K_RIGHT:
                        rotating = -1

                if event.type == pygame.KEYUP:
                    if event.key == pygame.K_UP:
                        thrusting = False
                    if event.key == pygame.K_LEFT or event.key == pygame.K_RIGHT:
                        rotating = 0

        if not game_over:
            lander.update(thrusting, rotating)
            result = lander.check_landing()
            if result:
                game_over = True

        # Drawing
        screen.fill(BLACK)

        # Draw platform
        pygame.draw.rect(screen, GREEN, platform)

        # Draw lander
        lander.draw()

        # Display fuel
        font = pygame.font.Font(None, 36)
        fuel_text = font.render(f"Fuel: {int(lander.fuel)}", True, WHITE)
        screen.blit(fuel_text, (10, 10))

        # Game over message
        if game_over:
            if result == "landed":
                message = "You landed successfully!"
            else:
                message = "You crashed!"
            game_over_text = font.render(message, True, RED)
            screen.blit(game_over_text, (WIDTH // 2 - 150, HEIGHT // 2))

            # Stop further updates to the lander
            lander.update(False, 0)

        pygame.display.flip()
        clock.tick(FPS)

    pygame.quit()

if __name__ == "__main__":
    main()
