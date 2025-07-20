from twinkle import Twinkle

if __name__ == "__main__":
    # target round
    ROUND = 5

    # # The number of active bits for the 4-round integral distinguisher
    # ACTIVEBITS = [0, 1, 2, 3]

    # # The number of active bits for the 5-round integral distinguisher
    ACTIVEBITS = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]

    twinkle = Twinkle(ROUND, ACTIVEBITS)
    twinkle.MakeModel()
    twinkle.SolveModel()
