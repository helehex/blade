# from infrared import G3
from pathlib import cwd
from python import Python, PythonObject
import time

from blade.algebra.signature import Signature

alias window_height = 1000
alias window_width = 1000
alias background_color = "black"
alias cell_color = "green"


def main():
    pygame = Python.import_module("pygame")

    # Initialize pygame modules
    pygame.init()

    # Create a window and set its title
    # window = pygame.display.set_mode((window_height, window_width))
    pygame.display.set_caption("Signature Explorer")


    border_size = 1
    cell_fill_color = pygame.Color(cell_color)
    background_fill_color = pygame.Color(background_color)

    running = True
    count = 0

    def draw_sig(sig: Signature):
        window = pygame.display.set_mode([sig.dims, sig.dims])
        pixels = pygame.PixelArray(window)
        # cell_height = window_height / sig.dims
        # cell_width = window_width / sig.dims

        for lhs_basis in range(sig.dims):
            for rhs_basis in range(sig.dims):
                    res_basis = sig.mul(lhs_basis, rhs_basis)
                    rev_basis = sig.mul(rhs_basis, lhs_basis)
                    var color = pygame.Color(255, 255, 255)
                    # grade = sig.grade(res_basis)
                    # if grade < sig.grds // 2:
                    #     color.hsva = (((sig.grds // 2) - grade) * (360 // sig.grds), 100, 100, 100)
                    # else:
                    # color.hsva = [(lhs_basis&rhs_basis) * (360 / sig.dims), 100, 100, 100]
                    color.hsva = [0, 0, (abs(res_basis.sign + rev_basis.sign)) * 50, 100]
                    pixels[lhs_basis, rhs_basis] = color
                    # pygame.draw.rect(window, color, (x, y, width, height))

        pixels.close()
        pygame.display.flip()

    draw_sig(Signature(4, 1))
    pygame.image.save(pygame.display.get_surface(), "temp_img.png")
    # while running:

    #     # Poll for events
    #     for event in pygame.event.get():
    #         if event.type == pygame.QUIT:
    #             # Quit if the window is closed
    #             running = False
    #         elif event.type == pygame.KEYDOWN:
    #             # Also quit if the user presses <Escape> or 'q'
    #             if event.key == pygame.K_ESCAPE or event.key == pygame.K_q:
    #                 running = False

    #     # Clear the window by painting with the background color
    #     # window.fill(background_fill_color)

    #     # # # Pause to let the user appreciate the scene
    #     # time.sleep(1.0)

    # Shut down pygame cleanly
    pygame.quit()